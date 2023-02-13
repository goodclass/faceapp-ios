import torch
from PIL import Image
import numpy as np
from .model import FullGenerator
from encode.encode_images import DEVICE


class FaceGAN(object):
    def __init__(self, model_file):
        self.model = FullGenerator(512, 512, 8, 2)
        self.model.load_state_dict(torch.load(model_file, map_location='cpu'))
        self.model.to(DEVICE)
        self.model.eval()

    def process(self, img):
        img_t = self.img2tensor(img)
        img_t = img_t.to(DEVICE)

        with torch.no_grad():
            out, __ = self.model(img_t)
        out = self.tensor2img(out)
        return out


    def img2tensor(self, image):
        img_t = (torch.from_numpy(np.array(image))/255. - 0.5) / 0.5
        img_t = img_t.permute(2, 0, 1).unsqueeze(0)
        return img_t


    def tensor2img(self, image_tensor, pmax=255.0, imtype=np.uint8):
        image_tensor = image_tensor * 0.5 + 0.5
        image_tensor = image_tensor.squeeze(0).permute(1, 2, 0)
        image_numpy = np.clip(image_tensor.float().cpu().numpy(), 0, 1) * pmax
        return Image.fromarray(image_numpy.astype(imtype))
