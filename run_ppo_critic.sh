#!/bin/bash

# docker run -it --gpus all  --ipc=host --net host --ulimit memlock=-1 --ulimit stack=67108864 -v "/home/gleibovich/work:/workspace" nemo-aligner:20240105-nemo-1.22.0-mlm-0.4.0-TE-1.1_p
# cd /opt/NeMo-Aligner && \ 
# export PYTHONPATH="/opt/NeMo-Aligner:" && \ 
# export HYDRA_FULL_ERROR=1 && \ 
# export CUDA_VISIBLE_DEVICES=0 && \ 
# export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:128" && \
# export WANDB_API_KEY=656d898ceb43e7059b9ab57b2f85bb05d196b907 && \
# python -u ./examples/nlp/gpt/serve_ppo_critic.py \ 
# --config-path=./examples/nlp/gpt/conf/ \ 
# --config-name=gpt_ppo_critic trainer.ppo.inference_micro_batch_size=1 trainer.devices=1 trainer.num_nodes=1 \ 
# exp_manager.explicit_log_dir=./results/nemo-aligner/critic_rm/critic_results \ 
# exp_manager.create_wandb_logger=False  \
# trainer.ppo.port=5567 ++model.num_attributes=1 ++model.offload_adam_states=True ++model.micro_batch_size=1 ++model.global_batch_size=64 ++model.tensor_model_parallel_size=1 \ 
# pretrained_checkpoint.restore_from_path=/home/gkoren/scratch/models_ckpts/nemo_aligner/gpt2b/gpt_2b_rm_from_shami.nemo ++model.mcore_gpt=True exp_manager.create_checkpoint_callback=True

##############################################
# to run the critic server: 
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:128" && \
export WANDB_API_KEY=656d898ceb43e7059b9ab57b2f85bb05d196b907 && \
python ./examples/nlp/gpt/serve_ppo_critic.py --config-path=./conf/ --config-name=gpt_ppo_critic trainer.ppo.inference_micro_batch_size=1 trainer.devices=1 trainer.num_nodes=1 exp_manager.explicit_log_dir=./results/nemo-aligner/critic_rm/critic_results exp_manager.create_wandb_logger=False trainer.ppo.port=5567 ++model.num_attributes=1 ++model.offload_adam_states=True ++model.micro_batch_size=1 ++model.global_batch_size=64 ++model.tensor_model_parallel_size=1 pretrained_checkpoint.restore_from_path=/home/gkoren/scratch/models_ckpts/nemo_aligner/gpt2b/gpt_2b_rm_from_shami.nemo ++model.mcore_gpt=True exp_manager.create_checkpoint_callback=True


##############################################
# to run the ppo on another server
# export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:128"
# # to run the ppo actor
# python ./examples/nlp/gpt/train_gpt_ppo_actor.py --config-path=./conf/ --config-name=gpt_ppo_actor \
# "++model.data.data_prefix={train: [/opt/NeMo-Aligner/data/rm_ppo/hh_comparison_train_text_document], validation: [/opt/NeMo-Aligner/data/rm_ppo/hh_prompts_test_text_document], test: [/opt/NeMo-Aligner/data/rm_ppo/hh_prompts_test_text_document]}" model.ppo.num_rollout_samples=64 model.ppo.rollout_micro_batch_size=1 pretrained_checkpoint.restore_from_path=/home/gkoren/scratch/models_ckpts/nemo_aligner/gpt2b/2B_mcore_conv_sft_gbs_128.nemo exp_manager.explicit_log_dir=./results/nemo-aligner/actor/actor_results exp_manager.create_wandb_logger=True exp_manager.wandb_logger_kwargs.name=gkoren_gpt_2b_ppo_actor exp_manager.wandb_logger_kwargs.project=2B_mcore_gpt_aligner ++exp_manager.wandb_logger_kwargs.entity="nvidia" trainer.num_nodes=1 trainer.devices=1 ++trainer.ppo.val_num_logged_table_prompts=10 trainer.ppo.val_check_interval=1 ++model.micro_batch_size=1 ++model.global_batch_size=64 ++model.activations_checkpoint_granularity=selective ++model.activations_checkpoint_method=uniform ++model.tensor_model_parallel_size=1 ++model.pipeline_model_parallel_size=1 remote_critic_rm.critic.ip=10.176.2.234 remote_critic_rm.critic.port=5567 model.data.data_impl=mmap