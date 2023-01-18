# rest_framework
import json
import time

from .BaseResponse import IResponse
from rest_framework.views import APIView
from django.core import serializers
from .models import UserTodo


class hello(APIView):
    def get(self, request):
        ip = request.META.get("REMOTE_ADDR")
        ipNe = request.META.get("HTTP_USER_AGENT")
        data = request.META
        cookies = request.COOKIES
        print(cookies)
        for d in data:
            print("{} : {}".format(d, data[d]))
        return IResponse.simple({'data': 1,
                                 'ip': ip,
                                 'ip2': ipNe,
                                 'cookies': cookies})


class User(APIView):
    def get(self, req):
        user = {"name": "g1", "sex": 0, "number": 1, "likes": "女"}
        return IResponse.simple(user)


class UserList(APIView):
    def get(self, req):
        users = [
            {"name": "g1", "sex": 0, "number": 1, "likes": "女"},
            {"name": "g2", "sex": 1, "number": 2, "likes": "女1"},
            {"name": "g3", "sex": 1, "number": 3, "likes": "女3"},
            {"name": "g4", "sex": 0, "number": 4, "likes": "女5"}
        ]
        return IResponse.simple(users)


class UserTodoView(APIView):
    def get(self, req):
        tasks = serializers.serialize('json', UserTodo.objects.all().order_by("order"))
        tasks = json.loads(tasks)
        return IResponse.simple({"tasks": [task['fields'] for task in tasks]})

    def post(self, req):
        text = req.data.get('text', '')
        order = req.data.get('order', '')
        done = req.data.get('done', False)
        if text == '':
            return IResponse.simple_error(1, "创建失败！")
        try:
            order = int(order)
            task = UserTodo.objects.get(order=order)
            task.text = text
            task.done = done
            task.save()
            return IResponse.simple({
                "order": str(order),
                "text": text,
                "done": done,
            })
        except:
            order = int(time.time()*1000)
            try:
                UserTodo(order=order, text=text, done=bool(done)).save()
                return IResponse.simple({
                    "order": str(order),
                    "text": text,
                    "done": done,
                })
            except Exception as err:
                print("err = ", err)
                return IResponse.simple_error(2, "保存失败！")

    def put(self, req):
        try:
            src = int(req.data['src'])
            target = int(req.data['target'])
        except:
            return IResponse.simple_error(1, "请求参数错误！")
        try:
            src = UserTodo.objects.get(order=src)
            src.order = target - 1
            src.save()
            return IResponse.simple({
                    "order": str(src.order),
                    "text": src.text,
                    "done": src.done,
                })
        except Exception as err:
            print("err = ", err)
            return IResponse.simple_error(2, "保存失败！")

    def delete(self, req):
        t_id = int(req.query_params.get('id', 0))
        if t_id == 0:
            return IResponse.simple_error(1, "删除失败！")
        try:
            UserTodo.objects.get(order=t_id).delete()
            return IResponse.simple()
        except Exception as err:
            print("err = ", err)
            return IResponse.simple_error(2, "删除失败！")
