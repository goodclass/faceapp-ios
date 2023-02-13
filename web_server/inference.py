import torch
from PIL import Image
from encode.utils import tensor2im

from encode.face_alignment import align_image
from encode.encode import gs_netface
from encode.encode_images import encodeImage, init_encode
from encode.models.stylegan2_cpu.model import Generator


def get_latent(image):
    # 对齐
    ali_image = align_image(image)
    # 提高清晰度
    gs_image = gs_netface.process(ali_image)
    # 生成潜码
    latent_id = encodeImage(gs_image)
    return latent_id


def get_model():
    model = Generator(1024, 512, 8, channel_multiplier=1)
    para = torch.load("checkpoints/stylegan2-ffhq-config-e2.pt")
    model.load_state_dict(para["g_ema"])
    model.eval()
    return model


def press_edit(model, option, latent, factor_range=(-6, -3, 0, 3, 6)):
    edit_file = 'edit_latent/'+option+'.pt'
    direction = torch.load(edit_file)
    edit_latents = []
    for f in factor_range:
        edit_latent = latent + f * direction
        edit_latents.append(edit_latent)
    edit_latents = torch.stack(edit_latents).squeeze(1)

    with torch.no_grad():
        images, _ = model([edit_latents], randomize_noise=False, input_is_latent=True)
        images = [image for image in images]
        image_sum = torch.cat(images, dim=2)
        final_image = tensor2im(image_sum)
        final_image.show()

if __name__ == '__main__':
    # ['inference', 'age', 'beauty', 'gender', 'smile']
    option = 'gender'

    init_encode()
    image = Image.open("image/raw.jpg").convert('RGB')
    latent = get_latent(image)

    model = get_model()
    if option == 'inference':
        with torch.no_grad():
            images, _ = model([latent], randomize_noise=False, input_is_latent=True)
            final_image = tensor2im(images[0])
            final_image.show()
    else:
        press_edit(model, option, latent)