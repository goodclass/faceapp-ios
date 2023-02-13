import torch
import torchvision.transforms as transforms
from argparse import Namespace
from .models.e4e import e4e

DEVICE = "cpu"


def init_encode():
    global gs_network, gs_avg_image

    if gs_network is None:
        opts = {'checkpoint_path': "./checkpoints/best_model.pt", 'device': DEVICE, 'resize_outputs': None,
                'output_size': 1024, 'encoder_type': "ProgressiveBackboneEncoder", 'input_nc': 6}
        opts = Namespace(**opts)
        gs_network = e4e(opts)
        gs_network.eval()
        gs_network.to(DEVICE)
        if DEVICE == "cuda":
            gs_network.half()
            gs_network.latent_avg = gs_network.latent_avg.half()

        with torch.no_grad():
            avg = \
            gs_network(gs_network.latent_avg.unsqueeze(0), input_code=True, randomize_noise=False, average_code=True)[0]
            gs_avg_image = avg.to(DEVICE).detach()


def run_on_batch(inputs, net, avg_image, n_iters=3):
    y_hat, latent = None, None

    for iter in range(n_iters):
        if iter == 0:
            avg_image_for_batch = avg_image.unsqueeze(0).repeat(inputs.shape[0], 1, 1, 1)
            x_input = torch.cat([inputs, avg_image_for_batch], dim=1)
        else:
            x_input = torch.cat([inputs, y_hat], dim=1)
        codes = net.encoder(x_input)
        if x_input.shape[1] == 6 and latent is not None:
            codes = codes + latent
        else:
            codes = codes + net.latent_avg.repeat(codes.shape[0], 1, 1)
        if iter == n_iters - 1:
            return codes

        y_image, latent = net.decoder([codes], input_is_latent=True, randomize_noise=False, return_latents=True)
        y_hat = net.face_pool(y_image)


def encodeImage(from_im):
    global Gs_network, gs_avg_image

    with torch.no_grad():
        x = transforms(from_im)
        x = x.to(gs_avg_image)
        x.unsqueeze_(0)

        result_latents = run_on_batch(x, gs_network, gs_avg_image)
        result_latents = result_latents.float().cpu().detach()
        return result_latents


gs_network = None
gs_avg_image = None

transforms = transforms.Compose(
    [transforms.Resize((256, 256)), transforms.ToTensor(), transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])])
