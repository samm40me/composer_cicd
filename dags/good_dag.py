# Standard Imports
from datetime import timedelta
from uuid import uuid1
from pathlib import Path

# Third Party Imports
from airflow.decorators import task, dag
from airflow.utils.dates import days_ago
from airflow.operators.dummy import DummyOperator
from airflow.operators.bash import BashOperator
from airflow.operators.python import BranchPythonOperator
from airflow.utils.edgemodifier import Label
from airflow.providers.google.cloud.sensors.gcs import GCSObjectsWithPrefixExistenceSensor
from utils.cleanup import cleanup

default_args = {
    'start_date': days_ago(1),
    'catchup': False,
    'max_active_runs': 1,
    'tags': ["BAU"],
    'retries': 0
}


@dag(dag_id=Path(__file__).stem,
     schedule_interval="@once",
     description="DAG Demo",
     default_args=default_args)
def dag_main():
    start = DummyOperator(task_id='start')
    print_var = BashOperator(task_id='print_var',
                             bash_command='echo "Hello"')

    end = DummyOperator(task_id="end")

    start >> print_var >> end


# Invoke DAG
dag = dag_main()
