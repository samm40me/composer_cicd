"""Test integrity of DAGs."""
import glob
from pathlib import Path
from os import path
import importlib
import pytest
import sys
from airflow import models
from airflow.utils.dag_cycle_tester import check_cycle
sys.path.append(f"{Path(__file__).parents[1]}/dags")

DAG_PATHS = glob.glob(path.join(path.dirname(__file__),"..", "dags", "*.py"), recursive=True)


def _import_file(module_name, module_path):
    spec = importlib.util.spec_from_file_location(module_name, str(module_path))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@pytest.mark.parametrize("dag_path", DAG_PATHS)
def test_dag_integrity(dag_path):
    """Import DAG files and check for DAG."""
    dag_name = path.basename(dag_path)
    module = _import_file(dag_name, dag_path)

    # Validate if there is at least 1 DAG object in the file
    dag_objects = [var for var in vars(module).values() if isinstance(var, models.DAG)]

    # assert(Path(dag_path).stem == dag_objects[0]._dag_id)

    assert dag_objects

    # For every DAG object, test for cycles
    for dag in dag_objects:
        check_cycle(dag)