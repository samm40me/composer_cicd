from pathlib import Path

# Third Party Imports
from airflow.decorators import dag
import pendulum
from airflow.operators.empty import EmptyOperator
from airflow.operators.bash import BashOperator

default_args = {
    'start_date': pendulum.today('UTC').add(days=-1),
    'catchup': False,
    'max_active_runs': 1,
    'tags': ["BAU"],
    'retries': 0
}


@dag(dag_id=Path(__file__).stem,
     schedule_interval="@once",
     description="DAG CICD Demo",
     default_args=default_args)
def dag_main():
    start = EmptyOperator(task_id='start')

    print_var = BashOperator(task_id='print_var',
                             bash_command='echo "Hello"')

    end = EmptyOperator(task_id="end")

    start >> print_var >> end


# Invoke DAG
dag = dag_main()
