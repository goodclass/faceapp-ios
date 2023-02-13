from flask import request, Blueprint
from encode.utils import toJson
from PIL import Image
from queue import Queue
import base64, json
from encode.encode import put_data
from encode.face_alignment import align_image
from io import BytesIO
import torch

latent = Blueprint('encode', __name__)


@latent.route('/latentupload', methods=['POST'])
def latent_upload():
    receipt = request.form['receipt']
    receipt = receipt.replace(' ', '+')
    receipt = base64.b64decode(receipt)

    try:
        image = Image.open(BytesIO(receipt)).convert('RGB')
    except:
        return toJson(-1, "image is error !")

    align_img = align_image(image)
    if align_img is None:
        return toJson(-1, "face is not find")

    callQueve = Queue()
    put_data(align_img, callQueve)
    latent_data = callQueve.get()

    latent_path = "temp/latent.pt"
    torch.save(latent_data, latent_path)

    with open(latent_path, 'rb') as f:
        base64_str = base64.b64encode(f.read())
        latent_data = base64_str.decode('utf-8')

    data = {"ret": 0, "latent_data": latent_data}
    return json.dumps(data, ensure_ascii=False)
