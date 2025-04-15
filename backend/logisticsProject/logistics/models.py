from django.db import models
from django.db.models import JSONField

# User model
class User(models.Model):
    username = models.CharField(max_length=201)
    password = models.CharField(max_length=200)
    is_system_admin = models.BooleanField(default=False)

# District model
class District(models.Model):
    name = models.CharField(max_length=200)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True)

# Hospital model
class Hospital(models.Model):
    name = models.CharField(max_length=200)
    district = models.ForeignKey(District, on_delete=models.CASCADE, null=True)

# Refrigerator model
# Note: For demo purposes, only taking a subset of fields
# from the the doc shared by Professor Anderson. 
class Refrigerator(models.Model):
   name = models.CharField(max_length=200)
   model_id = models.CharField(max_length=200)
   manufacturer = models.CharField(max_length=200)
   temp_monitor_installed = models.BooleanField(default=False)
   monitor_type = models.CharField(max_length=200)
   monitor_working = models.BooleanField(default=False)
   voltage_regulator_installed =  models.BooleanField(default=False)
   regulator_type = models.CharField(max_length=200)
   vaccine_count = models.IntegerField(default=0)
   hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE, null=True)

# Log model
class Log(models.Model):

    # references
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    district = models.ForeignKey(District, on_delete=models.CASCADE)
    hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE)
    refrigerator = models.ForeignKey(Refrigerator, on_delete=models.CASCADE, null=True)

    previous_value = JSONField()
    new_value = JSONField()

    # record the time when the log is recorded 
    timestamp = models.DateTimeField()

class ConflictLog(models.Model):
    log = models.ForeignKey(Log, on_delete=models.CASCADE)

class LatestFridgeUpdates(models.Model):
    refrigerator = models.ForeignKey(Refrigerator, on_delete=models.CASCADE, null=True)
    timestamp = models.DateTimeField()

class Access(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length = 200) # user name
    district = models.ForeignKey(District, on_delete=models.CASCADE, null=True)
    hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE, null=True)