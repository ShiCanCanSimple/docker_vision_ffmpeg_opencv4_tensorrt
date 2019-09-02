ARG BASE_TAG=tf2_gpu_py3_jupyter_cv4_ffmpeg

FROM simplescc/vision:$BASE_TAG AS Builder

MAINTAINER Shi Cancan <simple_scc@163.com>

WORKDIR /root

#安装 pycuda
RUN apt-get install -y cuda-curand-dev-10.0 && \
	pip install pycuda

COPY *.deb .

#安装 tensorrt

RUN dpkg -i *.deb && \
	apt-key add /var/nv-tensorrt-repo-cuda10.0-trt5.1.5.0-ga-20190427/7fa2af80.pub && \
	apt-get update && \
	export RTVER=5.1.5-1+cuda10.0 && \
	export CUDNNVAR=7.6.3.30-1+cuda10.0 && \
	apt-get install -y libcudnn7=$CUDNNVAR libcudnn7-dev=$CUDNNVAR tensorrt libnvinfer5=$RTVER libnvinfer-dev=$RTVER python3-libnvinfer-dev=$RTVER uff-converter-tf=$RTVER && \
	apt-mark hold libcudnn7 libcudnn7-dev libnvinfer5 libnvinfer-dev python3-libnvinfer-dev uff-converter-tf && \
	rm *.deb

# 打补丁
RUN export TF_VER=`python   -c 'import tensorflow; print(tensorflow.__version__)'` ;\
	if [[ $TF_VER == 2.* ]]; then\
		echo 'patching...' ; \
		echo -e 'uff\ngraphsurgeon' | xargs -n1 -I{} grep -r 'import tensorflow' /usr/lib/python3.6/dist-packages/{} | awk -F ":" '{print $1}' | xargs -n1 sed -i 's/import tensorflow /import tensorflow.compat.v1 /g' ;\
		echo -e 'uff\ngraphsurgeon' | xargs -n1 -I{} grep -r 'from tensorflow' /usr/lib/python3.6/dist-packages/{} | awk -F ":" '{print $1}' | xargs -n1 sed -i 's/from tensorflow /from tensorflow.compat.v1 /g' ;\
	fi

# 打包
RUN export PY=/usr/local/lib/python3.6/dist-packages && \
	export PY2=/usr/lib/python3.6/dist-packages && \
	ls -1R --color=never \
	$PY/pycuda-*/* \
	$PY2/tensorrt-*/* \
	$PY2/graphsurgeon-*/* \
	$PY2/uff-*/* \
	/usr/lib/x86_64-linux-gnu/libcudnn*.so* \
	/usr/lib/x86_64-linux-gnu/libnvinfer*.so* \
	/usr/lib/x86_64-linux-gnu/libnvonnxparser*.so* \
	/usr/include/x86_64-linux-gnu/NvInfer*.h \
	/usr/include/x86_64-linux-gnu/cudnn_v7.h \
	/usr/include/cudnn.h \
	| xargs tar -cvf /root/pycuda_tensorrt.tar.gz \
	$PY/pycuda \
	$PY2/tensorrt \
	$PY2/graphsurgeon \
	$PY2/uff


FROM simplescc/vision:$BASE_TAG

WORKDIR /

COPY --from=Builder /root/pycuda_tensorrt.tar.gz .
RUN tar -xf pycuda_tensorrt.tar.gz  && rm pycuda_tensorrt.tar.gz