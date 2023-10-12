# %%
import pandas as pd
import csv

from bs4 import BeautifulSoup

# %%
# list of end use
end_use_list = ['Heating', 'Cooling', 'Interior Lighting', 
                'Interior Equipment', 'Fans', 'Total End Uses']

# parse end use data from each case html output
case_list = ['Baseline', 'CoolRoof_1', 'CoolRoof_2', 'CoolWall_1', 'CoolWall_2', 
             'InsRoof_1', 'InsRoof_2', 'InsWall_1', 'InsWall_2', 
             'LowEWin_1', 'LowEWin_2', 'SolarWin_1', 'SolarWin_2',
             'CeilingFan_1', 'CeilingFan_2', 'CeilingFan_NoSetback_1', 'CeilingFan_NoSetback_2',
             'Overhang_1', 'Shade_1','Shade_2',
             'HybridNV_WindowOpen_1', 'HybridNV_WindowOpen_2', 'HybridNV_OperationSchd_1', 'HybridNV_OperationSchd_2']
results_sum = []
for case_name, case_id in zip(case_list, range(1,25)):
    print('Start the processing of case id: '.format(case_id))
    with open("../output_files/init_{}.htm".format(case_id), encoding="utf-8") as f:
        data = f.read()
        soup = BeautifulSoup(data, 'html.parser')

        floor_area = 0

        results = {}
        results['location'] = 'JAKARTA'
        results['case_id'] = case_id
        results['floor_area'] = floor_area
        
        # parse the floor area
        i, j = 0, 0
        table = soup.find_all('table')[2]

        for row in table.find_all('tr'):
            cols = row.find_all('td')    
            for col in cols:
                i+=1
                col_text = col.get_text()
                if 'Net Conditioned Building Area' in col_text:
                    j = i+1
                if i == j:
                    floor_area += float(col_text)

        heating, cooling, lighting, equipment, fan = 0, 0, 0, 0, 0
        i, j = 0, 0
        table_list = soup.find_all('table')
        table_num=3
        table = soup.find_all('table')[table_num]
        for end_use in end_use_list:
            results = {}
            results['location'] = 'JAKARTA'
            results['case_name'] = case_name
            results['case_id'] = case_id
            results['floor_area'] = floor_area
            for row in table.find_all('tr'):
                cols = row.find_all('td')    
                for col in cols:
                    i+=1
                    col_text = col.get_text()
                    # print(col_text)
                    # mark the row number of the cooling coil
                    if end_use == col_text:
                        j = i+1
                    if i == j:
                        # print(col_text)
                        results['end_use'] = end_use
                        results['Electricity [kWh]'] = float(col_text)
                        print(results)
            results_sum.append(results)

# %% generate summary csv output file
keys = results_sum[0].keys()
with open('IDN_Res_JAKARTA_Summary.csv', 'w', newline='')  as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(results_sum)


