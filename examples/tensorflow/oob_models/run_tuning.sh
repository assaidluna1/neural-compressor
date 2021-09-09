#!/bin/bash
set -x

function main {

  init_params "$@"
  run_tuning

}

# init params
function init_params {

  for var in "$@"
  do
    case $var in
      --topology=*)
          topology=$(echo $var |cut -f2 -d=)
      ;;
      --dataset_location=*)
          dataset_location=$(echo $var |cut -f2 -d=)
      ;;
      --input_model=*)
          input_model=$(echo $var |cut -f2 -d=)
      ;;
      --output_model=*)
          output_model=$(echo $var |cut -f2 -d=)
      ;;
      *)
          echo "Error: No such parameter: ${var}"
          exit 1
      ;;
    esac
  done

}

models_need_name=(
--------
CRNN
CapsuleNet
CenterNet
CharCNN
Hierarchical_LSTM
MANN
MiniGo
TextCNN
TextRNN
aipg-vdcnn
arttrack-coco-multi
arttrack-mpii-single
context_rcnn_resnet101_snapshot_serenget
deepspeech
deepvariant_wgs
dense_vnet_abdominal_ct
east_resnet_v1_50
efficientnet-b0
efficientnet-b0_auto_aug
efficientnet-b5
efficientnet-b7_auto_aug
facenet-20180408-102900
handwritten-score-recognition-0003
license-plate-recognition-barrier-0007
optical_character_recognition-text_recognition-tf
pose-ae-multiperson
pose-ae-refinement
resnet_v2_200
show_and_tell
text-recognition-0012
vggvox
wide_deep
yolo-v3-tiny
NeuMF
PRNet
DIEN_Deep-Interest-Evolution-Network
--------
)

models_need_disable_optimize=(
--------
CRNN
efficientnet-b0
efficientnet-b0_auto_aug
efficientnet-b5
efficientnet-b7_auto_aug
vggvox
--------
)

# run_tuning
function run_tuning {
    input="input"
    output="predict"
    yaml='./config.yaml'
    extra_cmd=' --num_warmup 10 -n 500 '

    if [[ "${models_need_name[@]}"  =~ " ${topology} " ]]; then
      echo "$topology need model name!"
      extra_cmd+=" --model_name ${topology} "
    fi
    if [[ "${models_need_disable_optimize[@]}"  =~ " ${topology} " ]]; then
      echo "$topology need to disable optimize_for_inference!"
      extra_cmd+=" --disable_optimize "
    fi

    python tf_benchmark.py \
            --model_path ${input_model} \
            --output_path ${output_model} \
            --yaml ${yaml} \
            --tune \
            ${extra_cmd}

}

main "$@"
