# scripts/create_project.tcl

# === Récupération des arguments ===
set proj_name  [lindex $argv 0]
set part       [lindex $argv 1]
set top_module [lindex $argv 2]

set proj_dir "./build"

# === Création du projet ===
create_project $proj_name $proj_dir -part $part 
add_files [glob ./src/*.sv]
add_files -fileset sim_1 [glob ./tb/*.sv]
add_files -fileset constrs_1 [glob ./constr/*.xdc]
set_property top $top_module [current_fileset]
save_project_as $proj_name
