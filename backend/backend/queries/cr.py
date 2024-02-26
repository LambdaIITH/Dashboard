from pypika import Table, Query, Field, Column
from models import Slot_Change
from typing import List
import json 

slot_updates = Table('slot_updates')

def post_change(new_slot: Slot_Change):
    
    custom_timings_json = json.dumps(new_slot.custom_slot) if new_slot.custom_slot is not None else None
    query = (
        Query.into(slot_updates)
        .insert(
            new_slot.course_code, new_slot.acad_period, new_slot.user_id, new_slot.slot, custom_timings_json,
        )
    )
    return query.get_sql()


def update_CR_change(new_slot: Slot_Change):
    # Serialize the custom_slot dictionary to a JSON string if it is not None
    custom_timings_json = json.dumps(new_slot.custom_slot) if new_slot.custom_slot is not None else None

    query = (
        Query.update(slot_updates)
        .set(slot_updates.updated_slot, new_slot.slot)
        .set(slot_updates.custom_timings, custom_timings_json)  # Now passing a JSON string
        .where(
            (slot_updates.course_code == new_slot.course_code)
            & (slot_updates.acad_period == new_slot.acad_period)
            & (slot_updates.cr_id == new_slot.user_id)
        )
    )
    print(query.get_sql())
    return query.get_sql()

def delete_CR_change(course_code: str, acad_period: str, user_id: int):
    
    query = (
        Query.from_(slot_updates)
        .delete()
        .where(
            (slot_updates.course_code == course_code)
            & (slot_updates.acad_period == acad_period)
            & (slot_updates.cr_id == user_id)
        )
        
    )
    
    return query.get_sql()

def get_CR_changes(course_codes: List[str], acad_period: str):
    query = (
        Query.from_(slot_updates)
        .select("*")
        .where((slot_updates.course_code.isin(course_codes) ) & (slot_updates.acad_period == acad_period))
    )
    return query.get_sql()