"""
This file defines the core research contribution
"""
import math
import torch
from torch import nn

from ..models.encoders import restyle_e4e_encoders


class e4e(nn.Module):

    def __init__(self, opts):
        super(e4e, self).__init__()
        if opts.device == "cpu":
            from ..models.stylegan2_cpu.model import Generator
        else:
            from ..models.stylegan2_gpu.model import Generator

        self.set_opts(opts)
        self.n_styles = int(math.log(self.opts.output_size, 2)) * 2 - 2
        # Define architecture
        self.encoder = self.set_encoder()
        self.decoder = Generator(self.opts.output_size, 512, 8, channel_multiplier=1)
        self.face_pool = torch.nn.AdaptiveAvgPool2d((256, 256))
        # Load weights if needed
        self.load_weights()

    def set_encoder(self):
        if self.opts.encoder_type == 'ProgressiveBackboneEncoder':
            encoder = restyle_e4e_encoders.ProgressiveBackboneEncoder(50, 'ir_se', self.n_styles, self.opts)
        elif self.opts.encoder_type == 'ResNetProgressiveBackboneEncoder':
            encoder = restyle_e4e_encoders.ResNetProgressiveBackboneEncoder(self.n_styles, self.opts)
        else:
            raise Exception(f'{self.opts.encoder_type} is not a valid encoders')
        return encoder

    def load_weights(self):
        print(f'Loading ReStyle e4e from checkpoint: {self.opts.checkpoint_path}')
        ckpt = torch.load(self.opts.checkpoint_path, map_location='cpu')
        self.encoder.load_state_dict(self.__get_keys(ckpt, 'encoder'), strict=False)
        self.decoder.load_state_dict(self.__get_keys(ckpt, 'decoder'), strict=True)
        self.__load_latent_avg(ckpt)


    def forward(self, x, latent=None, resize=True, latent_mask=None, input_code=False, randomize_noise=True,
                inject_latent=None, return_latents=False, alpha=None, average_code=False):
        if input_code:
            codes = x
        else:
            codes = self.encoder(x)
            # residual step
            if x.shape[1] == 6 and latent is not None:
                # learn error with respect to previous iteration
                codes = codes + latent
            else:
                # first iteration is with respect to the avg latent code
                codes = codes + self.latent_avg.repeat(codes.shape[0], 1, 1)

        if latent_mask is not None:
            for i in latent_mask:
                if inject_latent is not None:
                    if alpha is not None:
                        codes[:, i] = alpha * inject_latent[:, i] + (1 - alpha) * codes[:, i]
                    else:
                        codes[:, i] = inject_latent[:, i]
                else:
                    codes[:, i] = 0

        if average_code:
            input_is_latent = True
        else:
            input_is_latent = not input_code

        images, result_latent = self.decoder([codes],
                                             input_is_latent=input_is_latent,
                                             randomize_noise=randomize_noise,
                                             return_latents=return_latents)

        if resize:
            images = self.face_pool(images)

        if return_latents:
            return images, result_latent
        else:
            return images

    def set_opts(self, opts):
        self.opts = opts

    def __load_latent_avg(self, ckpt, repeat=None):
        if 'latent_avg' in ckpt:
            self.latent_avg = ckpt['latent_avg'].to(self.opts.device)
            if repeat is not None:
                self.latent_avg = self.latent_avg.repeat(repeat, 1)
        else:
            self.latent_avg = None


    @staticmethod
    def __get_keys(d, name):
        if 'state_dict' in d:
            d = d['state_dict']
        d_filt = {k[len(name) + 1:]: v for k, v in d.items() if k[:len(name)] == name}
        return d_filt
