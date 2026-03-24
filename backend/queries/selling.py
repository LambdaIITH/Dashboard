
from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any, List

selling_table, selling_images_table = Table('selling'), Table('selling_images')
users = Table("users")


def insert_in_selling_table(form_data: Dict[str, Any], user_id: int):
    query = Query.into(selling_table).columns(
        'item_name', 'item_description', 'user_id', 'selling_price'
    ).insert(
        form_data['item_name'], form_data['item_description'], user_id, form_data['selling_price']
    )

    sql_query = query.get_sql()
    sql_query += " RETURNING *"

    return sql_query


def insert_selling_images(image_paths: list, post_id: int):
    query = Query.into(selling_images_table).columns('image_url', 'item_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)

    return query.get_sql()


def get_all_selling_items():
    query = """
            SELECT
                s.id,
                s.item_name,
                s.item_description,
                s.user_id,
                COALESCE(json_agg(si.image_url) FILTER (WHERE si.image_url IS NOT NULL), '[]') AS images,
                s.created_at,
                s.selling_price
            FROM
                selling s
            LEFT JOIN
                selling_images si ON s.id = si.item_id
            GROUP BY
                s.id, s.item_name, s.item_description, s.user_id, s.created_at, s.selling_price
            ORDER BY
                s.created_at DESC;
            """

    return query


def update_in_selling_table(item_id: int, form_data: Dict[str, Any]):
    query = Query.update(selling_table)

    for key, value in form_data.items():
        if key in ('item_name', 'item_description', 'selling_price'):
            query = query.set(selling_table[key], value)

    query = query.where(selling_table['id'] == item_id).get_sql()
    query += " RETURNING *"
    return query


def get_particular_selling_item(item_id: int):
    query = (Query.from_(selling_table)
             .join(users)
             .on(users['id'] == selling_table['user_id'])
             .select('*')
             .where(selling_table['id'] == item_id))
    return str(query)


def delete_an_item_images(item_id: int):
    query = Query.from_(selling_images_table).delete().where(selling_images_table['item_id'] == item_id)
    return str(query)


def get_all_image_uris(item_id: int):
    query = Query.from_(selling_images_table).select('image_url').where(selling_images_table['item_id'] == item_id)
    return str(query)


def search_selling_items(search_query: str, max_results: int = 10):
    query = (Query.from_(selling_table)
             .select('*')
             .where(
                 selling_table['item_name'].ilike(f'%{search_query}%') |
                 selling_table['item_description'].ilike(f'%{search_query}%')
             )
             .orderby(selling_table['created_at'], order=Order.desc)
             .limit(max_results)
             )
    return str(query)


def get_some_image_uris(item_ids: list):
    if not item_ids:
        return "SELECT item_id, image_url FROM selling_images WHERE FALSE"
    query = Query.from_(selling_images_table).select(
        selling_images_table['item_id'], selling_images_table['image_url']
    ).where(selling_images_table['item_id'].isin(item_ids))
    return str(query)


def get_selling_items_by_user(user_id: int):
    query = (Query.from_(selling_table)
             .select('*')
             .where(selling_table['user_id'] == user_id)
             .orderby(selling_table['created_at'], order=Order.desc)
             )
    return str(query)
