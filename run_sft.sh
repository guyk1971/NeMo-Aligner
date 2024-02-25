#!/bin/bash
python examples/nlp/gpt/train_gpt_sft.py \
   trainer.precision=bf16 \
   trainer.num_nodes=1 \
   trainer.devices=1 \
   trainer.sft.max_steps=-1 \
   trainer.sft.limit_val_batches=40 \
   trainer.sft.val_check_interval=1000 \
   model.megatron_amp_O2=True \
   model.restore_from_path=gpt2b_mcore.nemo \
   model.optim.lr=5e-6 \
   model.answer_only_loss=True \
   model.data.num_workers=0 \
   model.data.train_ds.micro_batch_size=1 \
   model.data.train_ds.global_batch_size=32 \
   model.data.train_ds.file_path=databricks-dolly-15k-output.jsonl \
   model.data.validation_ds.micro_batch_size=1 \
   model.data.validation_ds.global_batch_size=32 \
   model.data.validation_ds.file_path=databricks-dolly-15k-output.jsonl \
   exp_manager.create_wandb_logger=True \
   exp_manager.explicit_log_dir=./results \
   exp_manager.wandb_logger_kwargs.project=sft_run \
   exp_manager.wandb_logger_kwargs.name=dolly_sft_run \
   exp_manager.checkpoint_callback_params.save_nemo_on_train_end=True \
   exp_manager.resume_if_exists=True \
   exp_manager.resume_ignore_no_checkpoint=True \
   exp_manager.create_checkpoint_callback=True \
   exp_manager.checkpoint_callback_params.monitor=validation_loss