from PIL import Image
import json, hashlib


def tensor2im(var):
    var = var.cpu().detach().transpose(0, 2).transpose(0, 1).numpy()
    var = ((var + 1) / 2)
    var[var < 0] = 0
    var[var > 1] = 1
    var = var * 255
    return Image.fromarray(var.astype('uint8'))


def toJson(ret, message=""):
    data= {"ret": ret, "message": message}
    return json.dumps(data, ensure_ascii=False)