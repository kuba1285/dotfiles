#!/bin/sh

sed -i -e "/^\$script:downloadBaseDir = ''/c\$script:downloadBaseDir = '/data/data/com.termux/files/home/storage/movies'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:downloadWorkDir = ''/c\$script:downloadWorkDir = '/tmp'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:saveBaseDir = ''/c\$script:saveBaseDir = '/data/data/com.termux/files/home/storage/movies'" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:simplifiedValidation = \$false/c\$script:simplifiedValidation = \$true" $HOME/TVerRec*/conf/user_setting.ps1
sed -i -e "/^\$script:disableValidation = \$false/c\$script:disableValidation = \$true" $HOME/TVerRec*/conf/user_setting.ps1
