from airflow.utils.db import provide_session
from airflow.models import XCom
from airflow.decorators import task


@task.python(trigger_rule='all_done')
def cleanup(**kwargs):
    cleanup_xcom(**kwargs)

@provide_session
def cleanup_xcom(session=None, **kwargs):
    dag = kwargs['dag']
    dag_id = dag.dag_id
    # It will delete all xcom of the dag_id
    session.query(XCom).filter(XCom.dag_id == dag_id).delete()

