# 构建命令

```
# BASE_TAG默认值为tf2_gpu_py3_jupyter_cv4_ffmpeg
export BASE_TAG=<simplescc/vision基础镜像TAG>
sudo docker build --build-arg BASE_TAG=${BASE_TAG} -t "simplescc/vision:${BASE_TAG}_tensorrt" .
```

# 运行命令

```
sudo docker run -d --gpus all -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix  -p 8888:8888 -h 0.0.0.0 simplescc/vision:${BASE_TAG}_tensorrt
```

# # 包含的组件

tensorflow 2.0.0rc0 GPU

python3.6

jupyter

opencv 4.1.1 with ffmpeg

tensorrt

pycuda
