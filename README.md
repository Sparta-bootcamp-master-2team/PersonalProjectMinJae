# PersonalProjectMinJae

## Introduction

환율 정보를 불러오는 App입니다.<br>
 [@minjae-L](https://github.com/minjae-L) 

## Tech Stack

* Base: Xcode, Swift, iOS, Git
* UI: UIKit(Programmatic), AutoLayout, SnapKit
* Frameworks: Alamofire, RxSwift
* Architecture: MVVM
* Dependency Management: Swift Package Manager

## Project Structure

```
ExchangeCalculateApp
 ┣ Assets.xcassets
 ┃ ┣ AccentColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ AppIcon.appiconset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ BackgroundColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ ButtonColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ CellBackgroundColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ FavoriteColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ SecondaryTextColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ TextColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┗ Contents.json
 ┣ Base.lproj
 ┃ ┗ LaunchScreen.storyboard
 ┣ Controllers
 ┃ ┣ CalculatorViewController.swift
 ┃ ┗ ExchangeViewController.swift
 ┣ CoreData
 ┃ ┣ Delegates
 ┃ ┃ ┣ AppDelegate.swift
 ┃ ┃ ┗ SceneDelegate.swift
 ┃ ┣ ExchangeCalculateApp.xcdatamodeld
 ┃ ┃ ┣ ExchangeCalculateApp.xcdatamodel
 ┃ ┃ ┃ ┗ contents
 ┃ ┃ ┣ ExchangeCalculateAppV2.xcdatamodel
 ┃ ┃ ┃ ┗ contents
 ┃ ┃ ┗ .xccurrentversion
 ┃ ┣ MappingModel.xcmappingmodel
 ┃ ┃ ┗ xcmapping.xml
 ┃ ┣ FavoriteExchange+CoreDataClass.swift
 ┃ ┣ FavoriteExchange+CoreDataProperties.swift
 ┃ ┣ LastCurrency+CoreDataClass.swift
 ┃ ┣ LastCurrency+CoreDataProperties.swift
 ┃ ┣ LastExchange+CoreDataClass.swift
 ┃ ┗ LastExchange+CoreDataProperties.swift
 ┣ Extensions
 ┃ ┣ DiffableDataSource+Extension.swift
 ┃ ┗ UIAlertViewController+Extension.swift
 ┣ Model
 ┃ ┣ CoreDataHandler.swift
 ┃ ┣ EntityModel.swift
 ┃ ┣ ExchangeItemDTO.swift
 ┃ ┗ Model.swift
 ┣ Network
 ┃ ┗ NetworkManager.swift
 ┣ View
 ┃ ┣ Cell
 ┃ ┃ ┗ ExchangeTableViewCell.swift
 ┃ ┣ CalculatorView.swift
 ┃ ┣ EmptyView.swift
 ┃ ┗ ExchangeView.swift
 ┣ ViewModel
 ┃ ┣ CalculatorViewModel.swift
 ┃ ┣ ExchangeViewModel.swift
 ┃ ┗ ViewModelProtocol.swift
 ┗ Info.plist
```

## Features
|내용|화면|
|-|-----|
|현재 환율 정보를 불러와 테이블 뷰로 표시합니다.|![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 11 11 50](https://github.com/user-attachments/assets/f0671867-26e4-4bc9-88b9-1f1dd94c0703)|
|셀 선택 시 해당 환율을 달러 기준으로 계산할 수 있습니다. <br/> 숫자가 아닌 공백이나 문자 입력 시 경고창이 뜨도록 구현되었습니다.|![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 11 14 56](https://github.com/user-attachments/assets/e0cf729a-2f87-438b-8f6a-0b278869d66c)|
|즐겨찾기 버튼을 통해 원하는 항목을 테이블의 가장 상단에 위치하도록 조정할 수 있습니다.|![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 11 18 06](https://github.com/user-attachments/assets/74566a04-0354-4e79-b527-7ce3ad048014)|
|다크모드에 대응되는 색을 구현하였습니다.|![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 11 18 53](https://github.com/user-attachments/assets/7613c386-fe35-4197-933d-2e7394486990)|
|앱 종료 후 재실행 시 이전의 화면이 띄워지도록 구현하였습니다.|![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 11 20 56](https://github.com/user-attachments/assets/5a06f0cf-00b1-460e-93ac-86a2e891d664)|






