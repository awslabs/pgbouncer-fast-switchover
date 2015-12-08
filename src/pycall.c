/*
Copyright 2015-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). 
You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/asl/

or in the "license" file accompanying this file. 
This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

/*
 * pgbouncer-rr extension: call external python function
 */

#include <Python.h>
#include "bouncer.h"
#include <usual/pgutil.h>

char *pycall(PgSocket *client, char *username, char *query_str, char *py_file,
		char* py_function) {
	PyObject *pName = NULL, *pModule = NULL, *pFunc = NULL;
	PyObject *pArgs = NULL, *pValue = NULL;
	PyObject *ptype, *perror, *ptraceback;
	char *py_filetmp, *py_module, *ext;
	char *res = NULL;

	/* setup python module name, function name */
	py_filetmp = malloc(strlen(py_file) + 1);
	strcpy(py_filetmp, py_file);
	py_module = (char *) basename(py_filetmp);
	ext = strrchr(py_module, '.');
	if (ext)
		ext[0] = '\0';

	Py_Initialize();

	/* Set sys.path to include module file */
	PySys_SetArgv(0, &py_file);

	/* Load python module */
	pName = PyString_FromString(py_module);
	pModule = PyImport_Import(pName);
	if (pModule == NULL) {
		slog_error(client, "Python module <%s> did not load", py_module);
		goto finish;
	}

	/* Prepare to call python function */
	pFunc = PyObject_GetAttrString(pModule, py_function);
	if (!pFunc) {
		slog_error(client, "Python Function <%s> not found in module <%s>",
				py_function, py_module);
		goto finish;
	}
	if (!PyCallable_Check(pFunc)) {
		slog_error(client,
				"Python Function <%s> in module <%s> is not callable!",
				py_function, py_module);
		goto finish;
	}

	/* Call function with two arguments - username and query_str */
	pArgs = PyTuple_New(2);
	pValue = PyString_FromString(username);
	PyTuple_SetItem(pArgs, 0, pValue);
	pValue = PyString_FromString(query_str);
	PyTuple_SetItem(pArgs, 1, pValue);
	pValue = PyObject_CallObject(pFunc, pArgs);
	if (pValue == NULL) {
		slog_error(client, "Python Function <%s> failed to return a value",
				py_function);
		goto finish;
	}
	if (PyString_Check(pValue)) {
		res = malloc(strlen(PyString_AsString(pValue)) + 1);
		strcpy(res, PyString_AsString(pValue));
	} else {
		res = NULL;
	}

	finish:
	if (PyErr_Occurred()) {
		PyErr_Fetch(&ptype, &perror, &ptraceback);
		slog_error(client, "Python error: %s", PyString_AsString(perror));
	}
	free(py_filetmp);
	Py_XDECREF(pName);
	Py_XDECREF(pModule);
	Py_XDECREF(pFunc);
	Py_XDECREF(pArgs);
	Py_XDECREF(pValue);
	return res;
}

