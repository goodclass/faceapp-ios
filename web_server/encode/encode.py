import time
import traceback
import threading
from .encode_images import encodeImage, init_encode
from queue import Queue
from .models.face_model.face_gan import FaceGAN

gs_netface = FaceGAN("./checkpoints/GPEN-512.pth")


def put_data(image, callQueue):
    q.put((image, callQueue))


def doRun():
    while True:
        try:
            (align_img, callQueue) = q.get()
            begin = time.time()
            en_img = gs_netface.process(align_img)
            begin2 = time.time()
            latent = encodeImage(en_img)
            align_time = begin2 - begin; encode_time = time.time() - begin2; total = align_time + encode_time
            print("完成. 超分辨率时间{}, 编码时间{}, 总时间{}".format(align_time, encode_time, total))
            callQueue.put(latent)

        except Exception:
            traceback.print_exc()


def init_main():
    init_encode()
    thread = threading.Thread(target=doRun, args=())
    thread.start()


q = Queue(maxsize=0)
