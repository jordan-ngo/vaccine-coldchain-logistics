from django.urls import path, re_path
from django.views.decorators.csrf import csrf_exempt

from . import views

urlpatterns = [
    # path("fetchUserDistricts", csrf_exempt(views.fetchUserDistricts), name="fetchUserDistricts"),
    path("getAllDistricts", csrf_exempt(views.getAllDistricts), name="getAllDistricts"),
    path("getHospitalsByDistrictID", views.getHospitalsByDistrictID, name="getHospitalsByDistrictID"),
    path("getAllUserInfo", views.getAllUserInfo, name="getAllUserInfo"),
    path("updateFridge/<int:userId>/", views.updateFridge, name="updateFridge"),
    path("addHospital", views.addHospital, name="addHospital"),
    path("addUser", views.addUser, name="addUser"),
    path("addFridge", views.addFridge, name="addFridge"),
    path("getAllFridges", views.getAllFridges, name="getAllFridges"),
    path("getAllHospitals", views.getAllHospitals, name="getAllHospitals"),
    path("getLog", views.getLog, name="getLog"),
    path("getConflictLog", views.getConflictLog, name="getConflictLog"),
    path("logOut", views.logOut, name="logOut"),
    path("logIn/<str:username>/<str:password>", views.logIn, name="logIn"),
    path("reassignDM/<int:userId>/<int:newDistrictId>", views.reassignDM, name="reassignDM"),
    path("getHospitalAssignments/<int:userId>/", views.getHospitalAssignments, name="getHospitalAssignments"),
    path("getDistrictAssignments/<int:userId>/", views.getDistrictAssignments, name="getDistrictAssignments"),
    path("getRefrigerators/<int:hospitalId>/", views.getRefrigerators, name="getRefrigerators"),
    path("getAllAccess", views.getAllAccess, name="getAllAccess"),
    path("addAccess/<int:userId>/<int:districtId>", views.addAccess, name="addAccess"),
    path("getAccessHospitalAssignments/<int:userId>/", views.getAccessHospitalAssignments, name="getAccessHospitalAssignments"),
    path("getOneHospital/<int:hospitalId>/", views.getOneHospital, name="getOneHospital"),
    path("addLog", views.addLog, name="addLog"),
    path("updateLocal", views.updateLocal, name="updateLocal"),
]

 # re_path(r'^$', views.index, name='index'),
    #re_path(r'^getDistrict/(?P<district_id>[0-9]+)$', views.getDistrict, name='getDistrict'),
    # re_path(r'^getHospitalCount/(?P<district_id>[0-9]+)$', views.getHospitalCount, name='getHospitalCount'),
    # re_path(r'^getHospitalList/(?P<district_id>[0-9]+)$', views.getHospitalList, name='getHospitalList'),
    # #re_path(r'^getHospitalList/(?P<district_id>[0-9]+)$', views.getHospitalList, name='getHospitalList'),
    # re_path(r'^getHospitalById/(?P<district_id>[0-9]+)/(?P<hospital_id>[0-9]+)$', views.getHospitalById, name='getHospitalById'),
    # re_path(r'^getHospitalValueById/(?P<district_id>[0-9]+)/(?P<hospital_id>[0-9]+)$', views.getHospitalValueById, name='getHospitalValueById'),
    # re_path(r'^modifyHospitalById/(?P<district_id>[0-9]+)/(?P<hospital_id>[0-9]+)/(?P<value>[0-9]+)$', views.modifyHospitalById, name='modifyHospitalById'),
    # re_path(r'^addHospital', views.addHospital, name='addHospital'),