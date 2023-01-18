# Generated by Django 4.1.5 on 2023-01-19 09:46

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='UserTodo',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('order', models.IntegerField(unique=True, verbose_name='相对顺序')),
                ('text', models.TextField(verbose_name='文本内容')),
                ('done', models.BooleanField(verbose_name='是否已完成')),
            ],
            options={
                'verbose_name': 'UserTodo',
                'verbose_name_plural': 'UserTodo',
            },
        ),
    ]
