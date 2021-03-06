# EasyDownload for vCloud Air
(English follows )

本ツールを利用することで、対話方式で vCloud Air 上から vApp/OVF/ISO をダウンロード可能となります。
コマンド実行時には vCloud Air のログインアカウントを入力すればダウンロード対象などは
GUI で選択してダウンロードを開始することができます。

## 用意するもの
- PowerCLI (PowerCLI 6.0 Release 3 以降)
- OVFtool (Version 4.1.0 でテストをしています)
- vCloud Air のログインアカウント 

// PowerCLI のインストールについて
https://communities.vmware.com/blogs/cloudtalk/2016/04/18/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E3%82%92%E5%88%A9%E7%94%A8%E3%81%97%E3%81%9F%E4%BB%AE%E6%83%B3%E3%83%9E%E3%82%B7%E3%83%B3%E3%81%AE%E6%93%8D%E4%BD%9C-vpcdedicated-cloud-%E7%B7%A8

// OVFTool のインストールについて  
https://kb.vmware.com/kb/2138530

## 利用方法
PowerCLI 上で EasyDownload.ps1 を実行します。

https://communities.vmware.com/blogs/cloudtalk/2016/04/27/vcloud-air-%E4%B8%8A%E3%81%AE%E4%BB%AE%E6%83%B3%E3%83%9E%E3%82%B7%E3%83%B3%E7%AD%89%E3%82%92%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E3%81%AB%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95

---------------------------------------
## English

This tool is really friendly to download vApps/OVF/ISO from vCloud Air.
You don’t need to copy vCD URL. It will automatically retrieve from your login information.
It works for any environment on vCloud Air (Dedicated/VPC/OnDemand).

## Requirements
- PowerCLI (PowerCLI 6.0 Release 3 or later)
- OVFtool (Version 4.1.0 is recommended)
- Login Account for vCloud Air

// How to install PowerCLI
https://communities.vmware.com/blogs/cloudtalk/2016/04/18/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E3%82%92%E5%88%A9%E7%94%A8%E3%81%97%E3%81%9F%E4%BB%AE%E6%83%B3%E3%83%9E%E3%82%B7%E3%83%B3%E3%81%AE%E6%93%8D%E4%BD%9C-vpcdedicated-cloud-%E7%B7%A8

// How to install OVFTool  
https://kb.vmware.com/kb/2138530

## Usage
./EasyDownload.ps1
