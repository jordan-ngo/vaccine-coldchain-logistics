import json
from datetime import timezone

from django.core.serializers import serialize
from django.http import HttpResponse, JsonResponse
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from django.views.decorators.csrf import csrf_exempt

from .models import Hospital, District, User, Refrigerator, Log, ConflictLog
from .models import LatestFridgeUpdates


def getAllDistricts(request):
    district_list = District.objects.all()
    return HttpResponse(serialize('json', district_list), content_type="application/json")


def getAllUserInfo(request):
    user_list = User.objects.all()
    return HttpResponse(serialize('json', user_list), content_type="application/json")


def getAllHospitals(request):
    hospital_list = Hospital.objects.all()
    return HttpResponse(serialize('json', hospital_list), content_type="application/json")


def getLog(request):
    log_list = Log.objects.all()
    return HttpResponse(serialize('json', log_list), content_type="application/json")


def getConflictLog(request):
    conflict_list = ConflictLog.objects.all()
    return HttpResponse(serialize('json', conflict_list), content_type="application/json")


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

        return JsonResponse(
            {'role': None, 'errorMessage': 'password does not match', 'districts': None, 'userID': user.id})


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


def updateLocal(request):
    districts = fetchDistricts()
    return JsonResponse({'districts': districts})
