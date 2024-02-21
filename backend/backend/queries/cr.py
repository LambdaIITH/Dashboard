from pypika import Table, Query, Field, Column
from models import Slot_Change
from typing import List

slot_updates = Table('slot_updates')

def post_CR_change(new_slot: Slot_Change):
    query = (
        Query.into(slot_updates)
        .insert(
            new_slot.course_code, new_slot.acad_period, new_slot.user_id, new_slot.slot, new_slot.custom_slot,
        )
    )
    
    return query.get_sql()

def update_CR_change(new_slot: Slot_Change):
    query = (
        Query.update(slot_updates)
        .set(slot_updates.slot, new_slot.slot)
        .set(slot_updates.custom_slot, new_slot.custom_slot)
        .where(
            (slot_updates.course_code == new_slot.course_code)
            & (slot_updates.acad_period == new_slot.acad_period)
            & (slot_updates.user_id == new_slot.user_id)
        )
    )
    
    return query.get_sql()

def delete_CR_change(course_code: str, acad_period: str, user_id: int):
    query = (
        Query.from_(slot_updates)
        .delete()
        .where(
            (slot_updates.course_code == course_code)
            & (slot_updates.acad_period == acad_period)
            & (slot_updates.user_id == user_id)
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