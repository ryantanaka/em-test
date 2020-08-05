#!/usr/bin/env python3
import argparse
import logging
import sys

from datetime import datetime
from pathlib import Path

from Pegasus.api import *

logging.basicConfig(level=logging.DEBUG)

def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--inputs",
        nargs="+",
        required=True,
        help="workflow input files"
    )

    return parser.parse_args(args)

if __name__=="__main__":
    args = parse_args(sys.argv[1:])

    # --- Replica Catalog-------------------------------------------------------
    rc = ReplicaCatalog()
    ifs = []
    for f in args.inputs:
        p = Path(f)
        _if = File(p.name)
        ifs.append(_if)
        rc.add_replica("local", _if, p.resolve())
    
    rc.write()

    # --- Transformation Catalog -----------------------------------------------
    tc = TransformationCatalog()
    combine = Transformation(
                    "combine",
                    site="local",
                    pfn=(Path(".")/"combine.py").resolve(),
                    is_stageable=True
                )

    tc.add_transformations(combine)
    tc.write()

    # --- Workflow -------------------------------------------------------------
    wf = Workflow("test-workflow")

    of = File("out_{}.txt".format(int(datetime.now().timestamp())))
    combine_job = Job("combine")\
                    .add_args(of)\
                    .add_inputs(*ifs)\
                    .add_outputs(of)
    
    wf.add_jobs(combine_job)

    try:
        wf.plan()
    except PegasusClientError as e:
        print(e.output)
        sys.exit(1)

    

    

