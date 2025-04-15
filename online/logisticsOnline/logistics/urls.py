from django.urls import path, re_path
from django.views.decorators.csrf import csrf_exempt

from . import views

urlpatterns = [
    path("getAllDistricts", csrf_exempt(views.getAllDistricts), name="getAllDistricts"),
    path("getAllUserInfo", views.getAllUserInfo, name="getAllUserInfo"),
    path("getAllHospitals", views.getAllHospitals, name="getAllHospitals"),
    path("getLog", views.getLog, name="getLog"),
    path("getConflictLog", views.getConflictLog, name="getConflictLog"),
    path("logIn/<str:username>/<str:password>", views.logIn, name="logIn"),
    path("updateLocal", views.updateLocal, name="updateLocal"),
    path("reassignDM/<int:userId>/<int:newDistrictId>", views.reassignDM, name="reassignDM"),
    path("addLog", views.addLog, name="addLog"),
]