from django.db import models


class UserTodo(models.Model):
    order = models.IntegerField(verbose_name='相对顺序')
    text = models.TextField(verbose_name='文本内容')
    done = models.BooleanField(verbose_name='是否已完成', null=False)

    class Meta:
        verbose_name = 'UserTodo'
        verbose_name_plural = verbose_name

    def __str__(self):
        status_test = "未完成"
        if self.done:
            status_test = "已达成"
        return f"{self.order}_{self.text}_{status_test}"
