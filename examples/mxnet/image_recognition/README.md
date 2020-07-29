Step-by-Step
============

This document is used to list steps of reproducing MXNet ResNet18_v1/ResNet50_v1/Squeezenet1.0/MobileNet1.0/MobileNetv2_1.0/Inceptionv3 iLiT tuning zoo result.


# Prerequisite

### 1. Installation

  ```Shell
  pip install -r requirements.txt

  ```

### 2. Prepare Dataset
  You can use `prepare_dataset.sh` to download dataset for this example. like below:

  ```bash
  bash ./prepare_dataset.sh --dataset_location=./data
  ```
  
  This will download validation dataset val_256_q90.rec, it will put to the directory **./data/**

### 3. Prepare Pre-trained model
  You can use `prepare_model.py` to download model for this example. like below:
  ```python
  python prepare_model.py --model_name mobilenet1.0 --model_path ./model
  ```

  This will download the pre-trained model **mobilenet1.0**, and then put to the directory **./model/**. For more details, see below:

  ```python
  python prepare_model.py -h

  usage: prepare_model.py [-h]
                          [--model_name {resnet18_v1,resnet50_v1,squeezenet1.0,mobilenet1.0,mobilenetv2_1.0,inceptionv3}]
                          [--model_path MODEL_PATH] [--image_shape IMAGE_SHAPE]

  Prepare pre-trained model for MXNet ImageNet Classifier

  optional arguments:
    -h, --help            show this help message and exit
    --model_name {resnet18_v1,resnet50_v1,squeezenet1.0,mobilenet1.0,mobilenetv2_1.0,inceptionv3}
                          model to download, default is resnet18_v1
    --model_path MODEL_PATH
                          directory to put models, default is ./model
    --image_shape IMAGE_SHAPE
                          model input shape, default is 3,224,224

  ```
  


# Run
### ResNet18_v1
```bash
bash run_tuning.sh --topology=resnet18_v1 --dataset_location=./data/val_256_q90.rec --input_model=/PATH/TO/MODEL --output_model=./ilit_resnet18
```

### ResNet50_v1
```bash
bash run_tuning.sh --topology=resnet50_v1 --dataset_location=./data/val_256_q90.rec --input_model=/PATH/TO/MODEL --output_model=./ilit_resnet50_v1
```
### SqueezeNet1
```bash
bash run_tuning.sh --topology=squeezenet1.0 --dataset_location=./data/val_256_q90.rec --input_model=/PATH/TO/MODEL --output_model=./ilit_squeezenet
```
### MobileNet1.0
```bash
bash run_tuning.sh --topology=mobilenet1.0 --dataset_location=./data/val_256_q90.rec --input_model=/PATH/TO/MODEL --output_model=./ilit_mobilenet1.0
```
### MobileNetv2_1.0
```bash
bash run_tuning.sh --topology=mobilenetv2_1.0 --dataset_location=./data/val_256_q90.rec --input_model=/PATH/TO/MODEL --output_model=./ilit_mobilenetv2_1.0
```
### Inception_v3
```bash
bash run_tuning.sh --topology=inceptionv3 --dataset_location=./data/val_256_q90.rec --input_model=/PATH/TO/MODEL --output_model=./ilit_inception_v3
```

# Benchmark

Use resnet18 as an example:

```bash
# accuracy mode, run the whole test dataset and get accuracy
bash run_benchmark.sh --topology=resnet18_v1 --dataset_location=./data/val_256_q90.rec --input_model=./model --batch_size=32 --mode=accuracy

# benchmark mode, specify iteration number and batch_size in option, get throughput and latency
bash run_benchmark.sh --topology=resnet18_v1 --dataset_location=./data/val_256_q90.rec --input_model=./model --batch_size=32 --iters=100 --mode=benchmark
```

Examples of enabling iLiT auto tuning on MXNet ResNet50
=======================================================

This is a tutorial of how to enable a MXNet classification model with iLiT.

# User Code Analysis

iLiT supports two usages:

1. User specifies fp32 "model", calibration dataset "q_dataloader", evaluation dataset "eval_dataloader" and metric in tuning.metric field of model-specific yaml config file.

2. User specifies fp32 "model", calibration dataset "q_dataloader" and a custom "eval_func" which encapsulates the evaluation dataset and metric by itself.

>As ResNet50_v1/Squeezenet1.0/MobileNet1.0/MobileNetv2_1.0/Inceptionv3 series are typical classification models, use Top-K as metric which is built-in supported by iLiT. So here we integrate MXNet ResNet with iLiT by the first use case for simplicity.

### Write Yaml config file

In examples directory, there is a template.yaml. We could remove most of items and only keep mandotory item for tuning. 


```
#conf.yaml

framework:
  - name: mxnet

tuning:
    metric:
      - topk: 1
    accuracy_criterion:
      - relative: 0.01
    timeout: 0
    random_seed: 9527
```

Here we choose topk built-in metric and set accuracy target as tolerating 0.01 relative accuracy loss of baseline. The default tuning strategy is basic strategy. The timeout 0 means early stop as well as a tuning config meet accuracy target.


### code update

After prepare step is done, we just need update imagenet_inference.py like below.

```python
    import ilit
    fp32_model = load_model(symbol_file, param_file, logger)
    cnn_tuner = Tuner("./cnn.yaml")
    cnn_tuner.tune(fp32_model, q_dataloader=data, eval_dataloader=data)

```

The iLiT tune() function will return a best quantized model during timeout constrain.