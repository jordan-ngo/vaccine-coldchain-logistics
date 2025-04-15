import os
import django
import random

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'logisticsProject.settings')
django.setup()

from django.apps import apps
from django.db import transaction, IntegrityError
from logistics.models import User, District, Hospital, Refrigerator


# Reset all the tables to repopulate new mock data.
def clear_all_data():
    for model in apps.get_models():
        try:
            # Using transaction.atomic() to ensure that changes can be rolled back if needed
            with transaction.atomic():
                model.objects.all().delete()
        except IntegrityError as e:
            print(f"Failed to clear data from {model._meta.db_table}: {e}")


def create_fridge(hospital):
    name = f"fridge_{random.randint(1, 99999)}"
    model_id = f"model_{random.randint(100, 999)}"
    manufacturer = random.choice(['Manufacturer A', 'Manufacturer B', 'Manufacturer C'])
    temp_monitor_installed = random.choice([True, False])
    monitor_type = random.choice(['Type A', 'Type B']) if temp_monitor_installed else ''
    monitor_working = random.choice([True, False]) if temp_monitor_installed else False
    voltage_regulator_installed = random.choice([True, False])
    regulator_type = random.choice(['Regulator A', 'Regulator B']) if voltage_regulator_installed else ''
    vaccine_count = random.randint(0, 100)

    return Refrigerator.objects.create(
        name=name,
        model_id=model_id,
        manufacturer=manufacturer,
        temp_monitor_installed=temp_monitor_installed,
        monitor_type=monitor_type,
        monitor_working=monitor_working,
        voltage_regulator_installed=voltage_regulator_installed,
        regulator_type=regulator_type,
        vaccine_count=vaccine_count,
        hospital=hospital,
    )


def populate_data():
    # Create users, one admin and three users.
    _admin = User.objects.create(username="admin", password="logistics", is_system_admin=True)
    user1 = User.objects.create(username="user_1", password="password_1", is_system_admin=False)
    user2 = User.objects.create(username="user_2", password="password_2", is_system_admin=False)
    user3 = User.objects.create(username="user_3", password="password_3", is_system_admin=False)

    users = [user1, user2, user3]

    # Create 10 districts.
    districts = [District.objects.create(name=f"district_{i}") for i in range(1, 11)]
    districts_temp = []

    # Randomly assign districts to users, ensuring all are taken.
    random.shuffle(districts)
    while districts:
        for user in users:
            if districts:
                district = districts.pop()
                district.user = user
                district.save()
                districts_temp.append(district)

    districts = districts_temp

    # Create 30 hospitals.
    hospitals = [Hospital.objects.create(name=f"hospital_{i}") for i in range(1, 31)]

    # Randomly assign hospitals to districts, ensuring all are taken.
    while hospitals:

        for district in districts:
            if hospitals:

                # Get the hospital.
                hospital = hospitals.pop()

                # Create a number of fridges per hospital.
                num_fridges = random.randint(5, 10)
                for _ in range(num_fridges):
                    create_fridge(hospital)

                # Save the hospital district.
                hospital.district = district
                hospital.save()


if __name__ == '__main__':
    clear_all_data()  # Reset all backend tables.
    populate_data()  # Populate new backend tables from mock data.
