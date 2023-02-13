import torch
import base64
import requests
from inference import get_model
from encode.utils import tensor2im

if __name__ == '__main__':

    with open('image/raw.jpg', "rb") as f:
        data = f.read()
        image_base64_enc = base64.b64encode(data)
        image_base64_enc = str(image_base64_enc, 'utf-8')

    url = 'http://localhost:8800/latentupload'
    r = requests.post(url, data={"receipt": image_base64_enc})
    data = r.json()
    latent_data = data["latent_data"]

    latent_path = "temp/latent_test.pt"
    with open(latent_path, "wb") as fp:
        fp.write(base64.b64decode(latent_data))

    latent = torch.load(latent_path)

    model = get_model()
    images, _ = model([latent], randomize_noise=False, input_is_latent=True)
    final_image = tensor2im(images[0])
    final_image.show()
