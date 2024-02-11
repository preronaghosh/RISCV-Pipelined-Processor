#!/bin/bash
echo "===== Computer Architecture Course Environment Setup ====="
echo "Important: this script should be used as \`source env.sh\` and should only be used in bash"
export PROJECT_ROOT=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
echo -e "Project Root (\$PROJECT_ROOT):\t\t$PROJECT_ROOT"

##############################
# hack to make 4.210 works
# comment the following 
# lines out if running locally
mkdir -p $PROJECT_ROOT/bin_verilator
cp -r /usr/local/games/bin $PROJECT_ROOT/bin_verilator
ln -sf /usr/local/games/share/verilator/include $PROJECT_ROOT/bin_verilator/
ln -sf /usr/local/games/share/verilator/bin/verilator_ccache_report $PROJECT_ROOT/bin_verilator/bin/
ln -sf /usr/local/games/share/verilator/bin/verilator_includer $PROJECT_ROOT/bin_verilator/bin/
source /opt-src/bin/verilator421.sh
export VERILATOR_ROOT=$PROJECT_ROOT/bin_verilator/
##############################

export VERILATOR_VERSION=$(verilator --version 2>/dev/null | head -n 1)
echo -e "verilator Version (\$VERILATOR_VERSION):\t" $VERILATOR_VERSION
if [[ $VERILATOR_VERSION != *"4.210"* ]]; then
  echo -e "\033[0;31mERROR: verilator must be version 4.210\033[0m"
fi
export VIVADO_VERSION=$(vivado -version 2>/dev/null | head -n 1)
echo -e "Vivado Version (\$VIVADO_VERSION): \t" $VIVADO_VERSION
echo "===== Computer Architecture Course Environment Done  ====="
