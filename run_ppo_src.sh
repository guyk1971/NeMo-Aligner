docker run -it --gpus all  --ipc=host --net host --ulimit memlock=-1 --ulimit stack=67108864 -v "/home/gleibovich/work:/workspace" nemo-aligner:20240105-nemo-1.22.0-mlm-0.4.0-TE-1.1_p

cd /workspace/repos/NeMo-Aligner && \ 
export PYTHONPATH="/workspace/repos/NeMo-Aligner:" && \ 
export HYDRA_FULL_ERROR=1 && \ 
export CUDA_VISIBLE_DEVICES=0 && \ 
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:128" && \
export WANDB_API_KEY=<your_api_key> && \
python -u /workspace/repos/NeMo-Aligner/examples/nlp/gpt/serve_ppo_critic.py \ 
--config-path=/workspace/repos/NeMo-Aligner/examples/nlp/gpt/conf/ \ 
--config-name=gpt_ppo_critic trainer.ppo.inference_micro_batch_size=1 trainer.devices=1 trainer.num_nodes=1 \ 
exp_manager.explicit_log_dir=/workspace/results/nemo-aligner/critic_rm/critic_results \ 
exp_manager.create_wandb_logger=True exp_manager.wandb_logger_kwargs.name=gkoren_gpt_2b_ppo_critic exp_manager.wandb_logger_kwargs.project=2B_mcore_gpt_aligner ++exp_manager.wandb_logger_kwargs.entity="nvidia" \
trainer.ppo.port=5567 ++model.num_attributes=1 ++model.offload_adam_states=True ++model.micro_batch_size=1 ++model.global_batch_size=64 ++model.tensor_model_parallel_size=1 \ 
pretrained_checkpoint.restore_from_path=/workspace/checkpoints/mcore/rm/gpt-2b/gpt_2b_rm_from_shami.nemo ++model.mcore_gpt=True exp_manager.create_checkpoint_callback=True

