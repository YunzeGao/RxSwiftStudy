from rest_framework import status
from rest_framework.response import Response


class IResponse:
    @staticmethod
    def simple(data=None):
        res = IResponse(data=data)
        return Response(data=res.data, status=res.status_code)

    @staticmethod
    def simple_error(code: int, msg: str):
        res = IResponse(code=code, msg=msg)
        return Response(data=res.data, status=res.status_code)

    def __init__(self, code: int = 0, msg: str = '', data=None, status_code: status = status.HTTP_200_OK):
        self.code = code
        self.msg = msg
        self.data = {}
        self.status_code = status_code

        self.data['code'] = code
        self.data['msg'] = msg
        if data is None:
            self.data['data'] = ''
        else:
            self.data['data'] = data
