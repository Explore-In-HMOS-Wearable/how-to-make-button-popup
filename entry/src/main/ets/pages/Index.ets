import { router } from '@kit.ArkUI'
import {promptAction} from '@kit.ArkUI';


class Expense {
  category: string
  amount: number
  constructor(category: string, amount:number) {
    this.category = category
    this.amount = amount
  }

}
export class ExpenseStore{
  static expenses: Expense[] = []
  static addExpense(category: string, amount:number){
    ExpenseStore.expenses.push(new Expense(category,amount))
  }
  static getAll(): Expense[]{
    return ExpenseStore.expenses
  }
  static getTotalAmount(): number{
    return ExpenseStore.expenses.reduce((total, expense) => total + expense.amount,0)
  }
}
class MyDataSource implements IDataSource {
  private list: number[] = []

  constructor(list: number[]) {
    this.list = list
  }


  totalCount(): number {
    return this.list.length
  }

  getData(index: number): number {
    return this.list[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}

@Entry
@Component
struct Expenses {

  @State categories: string = ''
  @State amount: string = ''
  @State expenseList: Expense[] =[]
  @State handlePopup: boolean = false

  @Builder popupBuilder() {
    Row() {
      Text('Custom Popup with transitionEffect').fontSize(10)
    }.height(50).padding(5)
  }


  private data: MyDataSource = new MyDataSource([])
  list: number[] = []
  listIncome: string[] = []
  aboutToAppear(): void {

    for (let i = 1; i <= 2; i++) {
      this.list.push(i);
    }
    this.data = new MyDataSource(this.list)

  }

  onPageShow(): void {
    let newList = JSON.stringify(AppStorage.get("expenses"))

    console.log(newList)
  }

  addNewIncome(){
    this.list.push(this.list.length+1)
  }

  scroller: Scroller = new Scroller()
  scrollerForList: Scroller = new Scroller()
  private swiperController: SwiperController = new SwiperController()
  build() {
    Scroll(this.scroller){
      Column() {
        Text('Categories').margin({
          top: 20
        })
        TextInput({
          text: this.categories,
          placeholder: 'Categories'
        })
          .width('70%')
          .type(InputType.Normal)
          .onChange((value: string) =>{
            this.categories = value
          })
        Text('Amount')
        TextInput({
          text : this.amount,
          placeholder: 'Amount'
        })
          .width('70%')
          .type(InputType.Number)
          .onChange((value: string) =>{
            this.amount = value
          })
        Button("add").margin({
          top : 10
        }).onClick(() =>{

          this.handlePopup = !this.handlePopup
        }).bindPopup(this.handlePopup, {
          width : 200,
          message : "Please Confirm",
          primaryButton: {
            value: 'Confirm',
            action: () => {
              this.handlePopup = !this.handlePopup
              this.expenseList.push(new Expense(this.categories,Number(this.amount)))
              ExpenseStore.addExpense(this.categories, Number(this.amount))
              AppStorage.setOrCreate("expenses",this.expenseList)
              this.categories = ''
              this.amount = ''
            }
          },
          secondaryButton: {
            value : 'Cancel',
            action : () => {
              promptAction.showToast({
                message: "Deleted",
                duration: 2000,
                showMode: promptAction.ToastShowMode.TOP_MOST,
                bottom: 10
              })
              this.categories = ''
              this.amount = ''
              this.handlePopup = !this.handlePopup
            }
          },
          onStateChange: (e) => {
            if(!e.isVisible){
              this.handlePopup = false
            }
          }
        })
        Text("Lists").margin({
          top: 10
        })
        List({ space : 20, scroller: this.scrollerForList}){
          ForEach(this.expenseList,(item: Expense) => {
            ListItem(){
              Text(`${item.category} ${item.amount}`)
                .width('100%')
                .textAlign(TextAlign.Center).borderRadius(10)
            }
          })
        }
        .padding(16)
      }

      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }.scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
  }
}