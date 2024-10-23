from psycopg2 import sql
from datetime import datetime, timedelta
from dotenv import load_dotenv
import psycopg2
import os

load_dotenv()

DATABASE = os.getenv("DATABASE")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASS = os.getenv("POSTGRES_PASS")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")

try: 
    conn = psycopg2.connect(
        database=DATABASE,
        user=POSTGRES_USER,
        password=POSTGRES_PASS,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
    )
    print("Connected Successfully!\n")
except Exception as e:
    print(f"Connection Failed: {e}")

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
