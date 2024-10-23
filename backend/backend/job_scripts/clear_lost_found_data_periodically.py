from psycopg2 import sql
from datetime import datetime, timedelta
from utils import conn

def delete_old_records():
    try:
        cursor = conn.cursor()

        cutoff_date = datetime.now() - timedelta(days=28)

        delete_query = sql.SQL("""
            DELETE FROM lost
            WHERE created_at < %s;

            DELETE FROM found
            WHERE created_at < %s;
        """)

        cursor.execute(delete_query, (cutoff_date, cutoff_date))
        
        conn.commit()
        print(f"Deleted records older than {cutoff_date} from 'lost' and 'found' tables.")

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        if cursor:
            cursor.close()

if __name__ == '__main__':
    delete_old_records()
