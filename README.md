## Zapier Monthly Active Users Analysis

### Prerequisites

1. To run the Jupyter notebook in your local environment, the following should be installed on your machine.
    * Python 3.7
    * Anaconda or Miniconda for Python 3.7
        * [Download Anaconda here](https://www.anaconda.com/distribution/)
        * [Download Miniconda here](https://docs.conda.io/en/latest/miniconda.html)
2. Environment variables to connect to the Redshift cluster in a .bashrc or .bash_profile file. 
    The following names should be used:
    * ZAP_USER for user name
    * ZAP_PASS for password
    * ZAP_HOST for host
    * ZAP_DB for database 

### Creating a Jupyter kernel using the environment.yml file

1. From the project directory and using the command line, run the following to create a virtual environment using the environment.yml file.

    `conda env create -f environment.yml`

2. Activate the new virtual environment

    `source activate zapenv`
3. Create a Jupyter kernel for the new environment

    `python -m ipykernel install --user --name zapenv --display-name "zapenv"`

4. Start the Jupyter notebook server

    `jupyter notebook`
5. With the .ipynb file open in the browser, select **Kernel** then **zapenv** from the dropdown.

### Tool Chain
* The following open-source frameworks/libraries/tools have been chosen for this project:
    * Datagrip for SQL ETL development 
    * Jupyter for rapid prototyping, not optimal for productive-level software, it's a suitable choice for exploratory and experimentation
    * Pandas for data analysis, a reasonable choice for exploratory analysis and data transformations in a single-threaded environment.
    * Seaborn for data visualization
    * Prophet for automated timeseries forecasting, see the docs [here](https://facebook.github.io/prophet/).

### ETL Overview 
* A view called **active_users_analysis** has been created in the **jchumley** schema in the **zapier** database. 
    * See the script [here]()
    * Definitions of columns in the **active_users_analysis** view are are follows:
        * date: raw, no transformation applied
        * user_id: raw, no transformation applied
        * account_id: raw, no transformation applied
        * sum_tasks_used: raw, no transformation applied
        * cum_sum_tasks_used: 
            * Cumulative sum of **sum_tasks_used** for the date in question
            * Not used in the analysis but may come in use later
            * **SUM** operator window function
        * num_days_since_last_active: 
            * Computes the number of days since the user was last active based on the date for the given row in question
            * Used to determine if user is active or churned 
            * **LAG** operator window function 
        * active
            * Boolean value based on whether a user is considered active on the date in question
            * **CASE/WHEN** conditional based on **num_days_since_last_active** value s.t. num_days_since_last_active < 28 implies that a user is active
        * churned
            * Boolean value based on whether a user is considered churned on the date in question
            * **CASE/WHEN** conditional based on **num_days_since_last_active** value s.t. num_days_since_last_active > 27 and num_days_since_last_active < 56 implies user is churned
        * month_num
            * Numeric representation of month (e.g., January is 1)
            * Extracted from date using the Postgres/Redshift **DATE_PART** operator
        * month
            * String representation of month
            * Extracted from date using the Postgres/Redshift **DATE_PART** operator and **CASE/WHEN** conditionals 
        * dow_num
            * Numeric representation of day of week (e.g., Sunday is 0, Monday is 1, and so on)
            * Extracted from date using the Postgres/Redshift **DATE_PART** operator
        * dow 
            * String representation of day of week
            * Extracted from date using the Postgres/Redshift **DATE_PART** operator and **CASE/WHEN** conditionals

Author: Janel Roland Chumley 

Please email [janelchumley@gmail.com](janelchumley@gmail.com) for questions regarding this document. 
