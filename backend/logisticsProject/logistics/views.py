from datetime import datetime
from django.core import serializers
from django.core.serializers import serialize
import json
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from datetime import datetime, timezone

from .models import Hospital, District, User, Refrigerator, Log, ConflictLog, Access, LatestFridgeUpdates
from django.http import HttpResponse
from .models import Hospital, District, User, Refrigerator, Log, ConflictLog, Access
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt


def getAllDistricts(request):
    district_list = District.objects.all()
    return HttpResponse(serialize('json', district_list), content_type="application/json")


def getHospitalsByDistrictID(request):
    district_id = request.GET.get('district_id')
    if district_id != None and request.method == 'GET':
        try:
            hospitals = Hospital.objects.filter(district_id=district_id)
            serialized_hospitals = serialize('json', hospitals)
            return HttpResponse(serialized_hospitals, content_type='application/json')
        except Hospital.DoesNotExist:
            return HttpResponse("Hospitals not found", status=404)
    else:
        return HttpResponse("Invalid request method", status=405)


def getAllUserInfo(request):
    user_list = User.objects.all()
    return HttpResponse(serialize('json', user_list), content_type="application/json")

def getAllAccess(request):
    access_list = Access.objects.all()
    return HttpResponse(serialize('json', access_list), content_type="application/json")


@csrf_exempt
def addHospital(request):
    """"
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    hospitalArray = hospital.split(',')
    Hospital.objects.create(hospitalArray[0], hospitalArray[1], hospitalArray[2])
    return HttpResponse("added " + str(hospital))
    """
    if request.method == 'POST':
        for obj in serializers.deserialize('json', request.body):
            user_instance = obj.object  # Get the deserialized object
            user_instance.save()  # Save the object to the database
            print(user_instance)
    return HttpResponse("OK")


@csrf_exempt
def addUser(request):
    if request.method == 'POST':
        for obj in serializers.deserialize("json", request.body):
            user_instance = obj.object  # Get the deserialized object
            user_instance.save()  # Save the object to the database
            print(user_instance)
    return HttpResponse("OK")


@csrf_exempt
def addFridge(request):
    if request.method == 'POST':
        for obj in serializers.deserialize("json", request.body):
            user_instance = obj.object  # Get the deserialized object
            user_instance.save()  # Save the object to the database
            print(user_instance)
    return HttpResponse("OK")

@csrf_exempt
def addAccess(request, userId, districtId):
    aList = Access.objects.filter(user=userId, district=districtId)
    if aList.exists():
        return HttpResponse("OK")
    if request.method == 'POST':
        for obj in serializers.deserialize("json", request.body):
            user_instance = obj.object  # Get the deserialized object
            user_instance.save()  # Save the object to the database
            print(user_instance)
    return HttpResponse("OK")

def getAllFridges(request):
    fridge_list = Refrigerator.objects.all()
    return HttpResponse(serialize('json', fridge_list), content_type="application/json")


def getAllHospitals(request):
    hospital_list = Hospital.objects.all()
    return HttpResponse(serialize('json', hospital_list), content_type="application/json")


def getLog(request):
    log_list = Log.objects.all()
    return HttpResponse(serialize('json', log_list), content_type="application/json")


def getConflictLog(request):
    conflict_list = ConflictLog.objects.all()
    return HttpResponse(serialize('json', conflict_list), content_type="application/json")

def getRefrigerators(request, hospitalId):
    fridge_list = Refrigerator.objects.filter(hospital=hospitalId)
    return HttpResponse(serialize('json', fridge_list), content_type="application/json")


def logOut(request):
    return HttpResponse("OK")

def logIn(request, username, password):
    try:
        user = User.objects.get(username=username)
    except User.DoesNotExist:
        return JsonResponse({'role': None, 'errorMessage': 'user does not exist', 'districts': None, 'userID': None})

    if user.password == password:
        if user.is_system_admin:
            return JsonResponse({'role': 'admin', 'errorMessage': None, 'districts': None, 'userID': user.id})

        else:
            districts = fetchDistricts()
            return JsonResponse({'role': 'user', 'errorMessage': None, 'districts': districts, 'userID': user.id})

    else:

        return JsonResponse({'role': None, 'errorMessage': 'password does not match', 'districts': None, 'userID': user.id})

def fetchDistricts():

    districts = District.objects.all().prefetch_related(
        'hospital_set__refrigerator_set',
        'user'
    )

    data = []
    for district in districts:
        hospitals_data = []
        for hospital in district.hospital_set.all():
            refrigerators_data = [{
                'id': fridge.id,
                'name': fridge.name,
                'model_id': fridge.model_id,
                'manufacturer': fridge.manufacturer,
                'temp_monitor_installed': fridge.temp_monitor_installed,
                'monitor_type': fridge.monitor_type,
                'monitor_working': fridge.monitor_working,
                'voltage_regulator_installed': fridge.voltage_regulator_installed,
                'regulator_type': fridge.regulator_type,
                'vaccine_count': fridge.vaccine_count
            } for fridge in hospital.refrigerator_set.all()]

            hospitals_data.append({
                'id': hospital.id,
                'name': hospital.name,
                'refrigerators': refrigerators_data
            })

        user_id = district.user.id

        data.append({
            'id': district.id,
            'user_id': user_id,
            'name': district.name,
            'hospitals': hospitals_data,
        })

    print("data", data)

    return data



@csrf_exempt
def reassignDM(request, userId, newDistrictId):
    user = User.objects.get(pk=userId)
    if user is None:
        return HttpResponse("User does not exist")
    newDistrict = District.objects.get(pk=newDistrictId)
    if newDistrict is None:
        return HttpResponse("District does not exist")
    newDistrict.user = user
    newDistrict.save()
    return HttpResponse("OK")


def getHospitalAssignments(request, userId):
    user_id = int(userId)
    districtList = District.objects.filter(user=user_id)
    hospital_list = districtList.all().first().hospital_set.all()
    for district in districtList.all():
        hospital_list = district.hospital_set.all().union(hospital_list)
    return HttpResponse(serialize('json', hospital_list), content_type="application/json")

def getDistrictAssignments(request, userId):
    user_id = int(userId)
    districtList = District.objects.filter(user=user_id)
    return HttpResponse(serialize('json', districtList), content_type="application/json")

def getAccessHospitalAssignments(request, userId):
    user_id = int(userId)
    accessList = Access.objects.filter(user=user_id, district__isnull=True)
    return HttpResponse(serialize('json', accessList), content_type="application/json")

def getOneHospital(request, hospitalId):
    h_id = int(hospitalId)
    h = Hospital.objects.filter(id=hospitalId)
    return HttpResponse(serialize('json', h), content_type="application/json")


@csrf_exempt
def addLog(request):
    if request.method == 'POST':
        try:
            logs = json.loads(request.body)
        except json.JSONDecodeError as e:
            return HttpResponse(f"Failed to parse JSON data: {e}", status=400)
        for log in logs:
            try:
                user = User.objects.get(id=log['user'])
                district = District.objects.get(id=log['district'])
                hospital = Hospital.objects.get(id=log['hospital'])
                refrigerator = Refrigerator.objects.get(id=log['refrigerator']) if 'refrigerator' in log else None
                previous_value = json.loads(log.get('previous_value', '{}'))
                new_value = json.loads(log.get('new_value', '{}'))
                timestamp = parse_datetime(log.get('timestamp'))
                log_obj = Log(
                    user=user,
                    district=district,
                    hospital=hospital,
                    refrigerator=refrigerator,
                    previous_value=previous_value,
                    new_value=new_value,
                    timestamp=timestamp  # or use the timestamp from the log if provided
                )
                log_obj.save()
                if user != district.user:
                    conflict_log = ConflictLog(log=log_obj)
                    conflict_log.save()
                if LatestFridgeUpdates.objects.filter(refrigerator=refrigerator).exists():
                    latest_update = LatestFridgeUpdates.objects.get(refrigerator=refrigerator)
                    previous_time = latest_update.timestamp
                    timestamp_utc = timestamp.replace(tzinfo=timezone.utc)  # timezone workaround
                    if previous_time < timestamp_utc:
                        for key, value in new_value.items():
                            setattr(refrigerator, key, value)
                        refrigerator.save()
                        latest_update.timestamp = timestamp
                        latest_update.save()
                else:
                    latest_update = LatestFridgeUpdates(refrigerator=refrigerator, timestamp=timestamp)
                    for key, value in new_value.items():
                        setattr(refrigerator, key, value)
                    refrigerator.save()
                    latest_update.save()
            except json.JSONDecodeError as e:
                return HttpResponse(f"Failed to parse log values: {e}", status=400)
            except (User.DoesNotExist, District.DoesNotExist, Hospital.DoesNotExist, Refrigerator.DoesNotExist) as e:
                return HttpResponse(f"Related entity not found: {e}", status=400)
            except Exception as e:
                return HttpResponse(f"An error occurred: {e}", status=500)
        return HttpResponse("Logs processed successfully")
    else:
        return HttpResponse("Only POST requests are allowed", status=405)


@csrf_exempt
def logSolvers(request):
    if request.method == 'POST':
        logs = serializers.deserialize('json', request.body)
        # for log in log_solver_list:
        refrigerators_to_update = []
        for log in logs:
            refrigerators_to_update.append(log.refrigerator)
        latestFridges = LatestFridgeUpdates.objects.all()
        for log in logs:
            refrigerator = log.refrigerator
            latestUpdate = LatestFridgeUpdates.objects.get(pk=refrigerator)



def updateLocal(request):
    districts = fetchDistricts()
    return JsonResponse({'districts': districts})

@csrf_exempt
def updateFridge(request, userId):
    """"
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    hospitalArray = hospital.split(',')
    Hospital.objects.create(hospitalArray[0], hospitalArray[1], hospitalArray[2])
    return HttpResponse("added " + str(hospital))
    """
    if request.method == 'POST':
        user_id = int(userId)
        for obj in serializers.deserialize('json', request.body):
            fridge_instance = obj.object
        if not isinstance(fridge_instance, Refrigerator):
            return HttpResponse("Failed to update fridge")
        hospital = fridge_instance.hospital
        district = hospital.district
        timestamp = timezone.now()
        caller = User.objects.get(pk=user_id)
        if caller is None:
            return HttpResponse("User does not exist")
        old_fridge = Refrigerator.objects.get(pk=fridge_instance.id)
        if old_fridge is None:
            return HttpResponse("Fridge does not exist")
        log = Log(user=caller, district=district, hospital=hospital,
                  refrigerator=fridge_instance, previous_value=serialize("json", [old_fridge]),
                  new_value=serialize("json", [fridge_instance]), timestamp=timestamp)
        fridge_instance.save()
        # conflict occurs if the hospital being pushed to is in someone else's assigned district
        # This does not account for synchronization issues. Only when a user pushes to another person's hospital
        users = User.objects.all()
        log.save()
        for user in users:
            if user.id != caller.id:
                if district.user.id == user.id:
                    newLog = ConflictLog(log=log)
                    newLog.save()
        return HttpResponse("OK")
    else:
        return HttpResponse("Invalid request method", status=405)


"""

def getDistrict(request, district_id):
    district_list = District.objects.all()
    return HttpResponse(district_list[int(district_id)].name)

def getHospitalCount(request, district_id):
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    return HttpResponse(str(district.hospital_set.count()))

def getHospitalList(request, district_id):
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    return HttpResponse(district.hospital_set.all())

def getHospitalById(request, district_id, hospital_id):
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    return HttpResponse(district.hospital_set.all()[int(hospital_id)])

def getHospitalValueById(request, district_id, hospital_id):
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    return HttpResponse(district.hospital_set.all()[int(hospital_id)].value)

def modifyHospitalById(request, district_id, hospital_id, value):
    district_list = District.objects.all()
    district = district_list[int(district_id)]
    hospital = district.hospital_set.all()[int(hospital_id)]
    hospital.value = value
    hospital.save()
    return HttpResponse("changed Hospital value to " + str(value))
    
"""
