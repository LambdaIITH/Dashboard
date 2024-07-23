from typing import List, Tuple, Dict

from fastapi import HTTPException

def get_image_dict(images: List[Tuple[int, str]]) -> Dict[int, List[str]]:
    image_dict = {}
    for image in images:
        if image[0] not in image_dict:
            image_dict[image[0]] = []
        image_dict[image[0]].append(image[1])
    return image_dict

def authorize_edit_delete(table: str, item_id: int, user_id:int, conn):
    with conn.cursor() as cur: 
        cur.execute( f"SELECT {table}.user_id FROM {table} WHERE {table}.id = {item_id}" )
        
        authorized_id = cur.fetchone()
        if not authorized_id:
            raise HTTPException( status_code=404, detail="Item not found" )
        authorized_id = authorized_id[0]
        if authorized_id != user_id: 
            raise HTTPException( status_code=401, detail="User not Authorized" )