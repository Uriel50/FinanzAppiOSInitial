//
//  FinanzAppRepository.swift
//  FinanzApp
//
//  Created by Uriel Candia on 13/12/23.
//

import CoreData
import UIKit

class FinanzAppRepository {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }

    // MARK: - UserEntity Operations

    // ... Insert, Update, Delete para UserEntity ...

    func insertUser(userDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            // Iniciar el ID con 1, suponiendo que es el primero si no hay otros usuarios
            var newID: Int64 = 1

            // Crear una solicitud de búsqueda para obtener el ID máximo actual
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "userId", ascending: false)]
            fetchRequest.propertiesToFetch = ["userId"]
            fetchRequest.resultType = .dictionaryResultType

            do {
                // Ejecutar la solicitud de búsqueda
                let results = try self.context.fetch(fetchRequest)
                if let maxDictionary = results.first as? [String: Int64], let maxId = maxDictionary["userId"] {
                    // Si se obtiene un resultado, incrementar en 1 el ID máximo actual
                    newID = maxId + 1
                }
            } catch {
                print("Error al obtener el ID máximo: \(error)")
                // Manejar el error como se considere necesario
                completion(false)
                return
            }

            // Crear una nueva instancia de UserEntity con el nuevo ID
            let newUser = UserEntity(context: self.context)
            newUser.userId = newID
            newUser.userNickname = userDetails["userNickname"] as? String ?? ""
            newUser.userName = userDetails["userName"] as? String ?? ""
            newUser.userLastName = userDetails["userLastname"] as? String ?? ""
            newUser.userSex = userDetails["userSex"] as? String ?? ""
            newUser.userEmail = userDetails["userEmail"] as? String ?? ""
            newUser.userKey = userDetails["userKey"] as? String ?? ""

            do {
                try self.context.save()
                completion(true)
            } catch {
                print("Error al guardar el usuario: \(error)")
                completion(false)
            }
        }
    }


    func getUserById(email: String, completion: @escaping (UserEntity?) -> Void) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", email)
        fetchRequest.fetchLimit = 1
        
        context.perform {
            do {
                let result = try self.context.fetch(fetchRequest).first
                completion(result)
            } catch {
                completion(nil)
            }
        }
    }

    func getAllUsers(completion: @escaping ([UserEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        context.perform {
            do {
                let users = try self.context.fetch(fetchRequest)
                completion(users)
            } catch {
                completion([])
            }
        }
    }
    
    func userEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", email)
        
        context.perform {
            do {
                let count = try self.context.count(for: fetchRequest)
                completion(count > 0)
            } catch {
                print("Error al verificar el correo electrónico: \(error)")
                completion(false)
            }
        }
    }

    


    func updateUser(user: UserEntity, userDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            user.userNickname = userDetails["userNickname"] as? String ?? user.userNickname
            user.userName = userDetails["userName"] as? String ?? user.userName
            user.userLastName = userDetails["userLastname"] as? String ?? user.userLastName
            user.userSex = userDetails["userSex"] as? String ?? user.userSex
            user.userEmail = userDetails["userEmail"] as? String ?? user.userEmail
            user.userKey = userDetails["userKey"] as? String ?? user.userKey
            
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }


    func deleteUser(user: UserEntity, completion: @escaping (Bool) -> Void) {
        context.perform {
            self.context.delete(user)
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func getUserByEmail(email: String, completion: @escaping (UserEntity?) -> Void) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", email)
        fetchRequest.fetchLimit = 1
        context.perform {
            do {
                let result = try self.context.fetch(fetchRequest).first
                completion(result)
            } catch {
                completion(nil)
            }
        }
    }

    // MARK: - BudgetEntity Operations

    // ... Insert, Update, Delete para BudgetEntity ...

    func insertBudget(budgetDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            // Crear una solicitud de búsqueda para obtener el ID máximo actual
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BudgetEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "budgetId", ascending: false)]
            fetchRequest.propertiesToFetch = ["budgetId"]
            fetchRequest.resultType = .dictionaryResultType

            var newID: Int64 = 1
            do {
                // Ejecutar la solicitud de búsqueda
                let results = try self.context.fetch(fetchRequest)
                if let maxDictionary = results.first as? [String: Int64], let maxId = maxDictionary["budgetId"] {
                    // Si se obtiene un resultado, incrementar en 1 el ID máximo actual
                    newID = maxId + 1
                }
            } catch {
                print("Error al obtener el ID máximo del presupuesto: \(error)")
                // Manejar el error como se considere necesario
                completion(false)
                return
            }

            // Crear una nueva instancia de BudgetEntity con el nuevo ID
            let newBudget = BudgetEntity(context: self.context)
            newBudget.budgetId = newID // Usar el nuevo ID generado
            newBudget.nameBudget = budgetDetails["nameBudget"] as? String ?? ""
            newBudget.userEmailBudget = budgetDetails["userEmailBudget"] as? String ?? ""
            newBudget.userId = budgetDetails["userId"] as? Int64 ?? 0

            do {
                try self.context.save()
                completion(true)
            } catch {
                print("Error al guardar el presupuesto: \(error)")
                completion(false)
            }
        }
    }



    func getAllBudgets(completion: @escaping ([BudgetEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        
        context.perform {
            do {
                let budgets = try self.context.fetch(fetchRequest)
                completion(budgets)
            } catch {
                completion([])
            }
        }
    }

    func getBudgetByEmail(email: String, completion: @escaping ([BudgetEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailBudget == %@", email)
        
        context.perform {
            do {
                let budgets = try self.context.fetch(fetchRequest)
                completion(budgets)
            } catch {
                completion([])
            }
        }
    }

    func getBudgetNameByEmail(email: String, completion: @escaping (String?) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BudgetEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailBudget == %@", email)
        fetchRequest.propertiesToFetch = ["nameBudget"]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.fetchLimit = 1

        context.perform {
            do {
                let result = try self.context.fetch(fetchRequest) as? [NSDictionary]
                let name = result?.first?["nameBudget"] as? String
                completion(name)
            } catch {
                completion(nil)
            }
        }
    }

    func getBudgetIdByEmail(email: String, completion: @escaping (Int64?) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BudgetEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailBudget == %@", email)
        fetchRequest.propertiesToFetch = ["budgetId"]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.fetchLimit = 1

        context.perform {
            do {
                let result = try self.context.fetch(fetchRequest) as? [NSDictionary]
                let id = result?.first?["budgetId"] as? Int64
                completion(id)
            } catch {
                completion(nil)
            }
        }
    }


    func updateBudget(budget: BudgetEntity, budgetDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            budget.nameBudget = budgetDetails["nameBudget"] as? String ?? budget.nameBudget
            budget.userEmailBudget = budgetDetails["userEmailBudget"] as? String ?? budget.userEmailBudget
            budget.userId = budgetDetails["userId"] as? Int64 ?? budget.userId
            
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func deleteBudget(budget: BudgetEntity, completion: @escaping (Bool) -> Void) {
        context.perform {
            self.context.delete(budget)
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    
    // MARK: - IncomeEntity Operations

    // ... Insert, Update, Delete para IncomeEntity ...

    func insertIncome(incomeDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            // Crear una solicitud de búsqueda para obtener el ID máximo actual
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "IncomeEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "idIncome", ascending: false)]
            fetchRequest.propertiesToFetch = ["idIncome"]
            fetchRequest.resultType = .dictionaryResultType

            var newID: Int64 = 1
            do {
                // Ejecutar la solicitud de búsqueda
                let results = try self.context.fetch(fetchRequest)
                if let maxDictionary = results.first as? [String: Int64], let maxId = maxDictionary["idIncome"] {
                    // Si se obtiene un resultado, incrementar en 1 el ID máximo actual
                    newID = maxId + 1
                }
            } catch {
                print("Error al obtener el ID máximo del ingreso: \(error)")
                // Manejar el error como se considere necesario
                completion(false)
                return
            }

            // Crear una nueva instancia de IncomeEntity con el nuevo ID
            let newIncome = IncomeEntity(context: self.context)
            newIncome.idIncome = newID // Usar el nuevo ID generado
            newIncome.budgetId = incomeDetails["budgetId"] as? Int64 ?? 0
            newIncome.incomeName = incomeDetails["incomeName"] as? String ?? ""
            newIncome.incomeMount = incomeDetails["incomeMount"] as? Double ?? 0.0
            newIncome.incomeCategory = incomeDetails["incomeCategory"] as? String ?? ""
            newIncome.incomeDate = incomeDetails["incomeDate"] as? String ?? ""
            newIncome.userEmailIncome = incomeDetails["userEmailIncome"] as? String ?? ""

            do {
                try self.context.save()
                completion(true)
            } catch {
                print("Error al guardar el ingreso: \(error)")
                completion(false)
            }
        }
    }




    func getAllIncome(completion: @escaping ([IncomeEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()

        context.perform {
            do {
                let incomes = try self.context.fetch(fetchRequest)
                completion(incomes)
            } catch {
                completion([])
            }
        }
    }

    func getTotalIncomeByEmail(email: String, completion: @escaping (Double) -> Void) {
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailIncome == %@", email)
        
        context.perform {
            do {
                let incomes = try self.context.fetch(fetchRequest)
                let totalIncome = incomes.reduce(0) { $0 + $1.incomeMount }
                completion(totalIncome)
            } catch {
                completion(0)
            }
        }
    }

    func getIncomesByCategory(email: String, category: String, completion: @escaping ([IncomeEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailIncome == %@ AND incomeCategory == %@", email, category)

        context.perform {
            do {
                let incomes = try self.context.fetch(fetchRequest)
                completion(incomes)
            } catch {
                completion([])
            }
        }
    }

    func getIncomesByMonth(email: String, month: String, completion: @escaping ([IncomeEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        // Nota: La conversión de fechas debe ser adaptada según el formato utilizado en incomeDate
        let predicate = NSPredicate(format: "userEmailIncome == %@ AND incomeDate BEGINSWITH %@", email, month)
        fetchRequest.predicate = predicate

        context.perform {
            do {
                let incomes = try self.context.fetch(fetchRequest)
                completion(incomes)
            } catch {
                completion([])
            }
        }
    }
    func getIncomeByEmail(email: String, completion: @escaping ([IncomeEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailIncome == %@", email)

        context.perform {
            do {
                let incomes = try self.context.fetch(fetchRequest)
                completion(incomes)
            } catch {
                print("Error al obtener ingresos: \(error)")
                completion([])
            }
        }
    }



    func updateIncome(income: IncomeEntity, incomeDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            income.idIncome = incomeDetails["idIncome"] as? Int64 ?? income.idIncome
            income.budgetId = incomeDetails["budgetId"] as? Int64 ?? income.budgetId
            income.incomeName = incomeDetails["incomeName"] as? String ?? income.incomeName
            income.incomeMount = incomeDetails["incomeMount"] as? Double ?? income.incomeMount
            income.incomeCategory = incomeDetails["incomeCategory"] as? String ?? income.incomeCategory
            income.incomeDate = incomeDetails["incomeDate"] as? String ?? income.incomeDate
            income.userEmailIncome = incomeDetails["userEmailIncome"] as? String ?? income.userEmailIncome
            
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }


    func deleteIncome(income: IncomeEntity, completion: @escaping (Bool) -> Void) {
        context.perform {
            self.context.delete(income)
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }


    // MARK: - ExpenseEntity Operations

    // ... Insert, Update, Delete para ExpenseEntity ...

    func insertExpense(expenseDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            // Crear una solicitud de búsqueda para obtener el ID máximo actual
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ExpenseEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "idExpense", ascending: false)]
            fetchRequest.propertiesToFetch = ["idExpense"]
            fetchRequest.resultType = .dictionaryResultType

            var newID: Int64 = 1
            do {
                // Ejecutar la solicitud de búsqueda
                let results = try self.context.fetch(fetchRequest)
                if let maxDictionary = results.first as? [String: Int64], let maxId = maxDictionary["idExpense"] {
                    // Si se obtiene un resultado, incrementar en 1 el ID máximo actual
                    newID = maxId + 1
                }
            } catch {
                print("Error al obtener el ID máximo del gasto: \(error)")
                // Manejar el error como se considere necesario
                completion(false)
                return
            }

            // Crear una nueva instancia de ExpenseEntity con el nuevo ID
            let newExpense = ExpenseEntity(context: self.context)
            newExpense.idExpense = newID // Usar el nuevo ID generado
            newExpense.budgetId = expenseDetails["budgetId"] as? Int64 ?? 0
            newExpense.expenseName = expenseDetails["expenseName"] as? String ?? ""
            newExpense.expenseMount = expenseDetails["expenseMount"] as? Double ?? 0.0
            newExpense.expenseCategory = expenseDetails["expenseCategory"] as? String ?? ""
            newExpense.expenseDate = expenseDetails["expenseDate"] as? String ?? ""
            newExpense.userEmailExpense = expenseDetails["userEmailExpense"] as? String ?? ""

            do {
                try self.context.save()
                completion(true)
            } catch {
                print("Error al guardar el gasto: \(error)")
                completion(false)
            }
        }
    }



    func getAllExpenses(completion: @escaping ([ExpenseEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()

        context.perform {
            do {
                let expenses = try self.context.fetch(fetchRequest)
                completion(expenses)
            } catch {
                completion([])
            }
        }
    }

    func getTotalExpenseByEmail(email: String, completion: @escaping (Double) -> Void) {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailExpense == %@", email)

        context.perform {
            do {
                let expenses = try self.context.fetch(fetchRequest)
                let totalExpense = expenses.reduce(0) { $0 + $1.expenseMount }
                completion(totalExpense)
            } catch {
                completion(0)
            }
        }
    }

    func getExpensesByCategory(email: String, category: String, completion: @escaping ([ExpenseEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailExpense == %@ AND expenseCategory == %@", email, category)

        context.perform {
            do {
                let expenses = try self.context.fetch(fetchRequest)
                completion(expenses)
            } catch {
                completion([])
            }
        }
    }

    func getExpensesByMonth(email: String, month: String, completion: @escaping ([ExpenseEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        let predicate = NSPredicate(format: "userEmailExpense == %@ AND expenseDate BEGINSWITH %@", email, month)
        fetchRequest.predicate = predicate

        context.perform {
            do {
                let expenses = try self.context.fetch(fetchRequest)
                completion(expenses)
            } catch {
                completion([])
            }
        }
    }
    
    func getExpenseByEmail(email: String, completion: @escaping ([ExpenseEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailExpense == %@", email)

        context.perform {
            do {
                let expenses = try self.context.fetch(fetchRequest)
                completion(expenses)
            } catch {
                print("Error al obtener gastos: \(error)")
                completion([])
            }
        }
    }



    func updateExpense(expense: ExpenseEntity, expenseDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            expense.idExpense = expenseDetails["idExpense"] as? Int64 ?? expense.idExpense
            expense.budgetId = expenseDetails["budgetId"] as? Int64 ?? expense.budgetId
            expense.expenseName = expenseDetails["expenseName"] as? String ?? expense.expenseName
            expense.expenseMount = expenseDetails["expenseMount"] as? Double ?? expense.expenseMount
            expense.expenseCategory = expenseDetails["expenseCategory"] as? String ?? expense.expenseCategory
            expense.expenseDate = expenseDetails["expenseDate"] as? String ?? expense.expenseDate
            expense.userEmailExpense = expenseDetails["userEmailExpense"] as? String ?? expense.userEmailExpense

            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }


    func deleteExpense(expense: ExpenseEntity, completion: @escaping (Bool) -> Void) {
        context.perform {
            self.context.delete(expense)
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    // MARK: - TotalsEntity Operations

    // ... Insert, Update, Delete para TotalsEntity ...

    func insertTotal(totalDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            // Crear una solicitud de búsqueda para obtener el ID máximo actual
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TotalsEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "idTotal", ascending: false)]
            fetchRequest.propertiesToFetch = ["idTotal"]
            fetchRequest.resultType = .dictionaryResultType

            var newID: Int64 = 1
            do {
                // Ejecutar la solicitud de búsqueda
                let results = try self.context.fetch(fetchRequest)
                if let maxDictionary = results.first as? [String: Int64], let maxId = maxDictionary["idTotal"] {
                    // Si se obtiene un resultado, incrementar en 1 el ID máximo actual
                    newID = maxId + 1
                }
            } catch {
                print("Error al obtener el ID máximo del total: \(error)")
                // Manejar el error como se considere necesario
                completion(false)
                return
            }

            // Crear una nueva instancia de TotalsEntity con el nuevo ID
            let newTotal = TotalsEntity(context: self.context)
            newTotal.idTotal = newID // Usar el nuevo ID generado
            newTotal.budgetId = totalDetails["budgetId"] as? Int64 ?? 0
            newTotal.totalIncome = totalDetails["totalIncome"] as? Double ?? 0.0
            newTotal.totalExpense = totalDetails["totalExpense"] as? Double ?? 0.0
            newTotal.balanceTotal = totalDetails["balanceTotal"] as? Double ?? 0.0
            newTotal.userEmailTotal = totalDetails["userEmailTotal"] as? String ?? ""

            do {
                try self.context.save()
                completion(true)
            } catch {
                print("Error al guardar el total: \(error)")
                completion(false)
            }
        }
    }


    func getAllTotals(completion: @escaping ([TotalsEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()

        context.perform {
            do {
                let totals = try self.context.fetch(fetchRequest)
                completion(totals)
            } catch {
                completion([])
            }
        }
    }

    func getTotalById(idTotal: Int64, completion: @escaping (TotalsEntity?) -> Void) {
        let fetchRequest: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idTotal == %ld", idTotal)

        context.perform {
            do {
                let total = try self.context.fetch(fetchRequest).first
                completion(total)
            } catch {
                completion(nil)
            }
        }
    }

    func getTotalByEmail(email: String, completion: @escaping (TotalsEntity?) -> Void) {
        let fetchRequest: NSFetchRequest<TotalsEntity> = TotalsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailTotal == %@", email)
        fetchRequest.fetchLimit = 1

        context.perform {
            do {
                let total = try self.context.fetch(fetchRequest).first
                completion(total)
            } catch {
                completion(nil)
            }
        }
    }


    func updateTotal(total: TotalsEntity, totalDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            total.totalIncome = totalDetails["totalIncome"] as? Double ?? total.totalIncome
            total.totalExpense = totalDetails["totalExpense"] as? Double ?? total.totalExpense
            total.balanceTotal = totalDetails["balanceTotal"] as? Double ?? total.balanceTotal
            total.userEmailTotal = totalDetails["userEmailTotal"] as? String ?? total.userEmailTotal

            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func deleteTotal(total: TotalsEntity, completion: @escaping (Bool) -> Void) {
        context.perform {
            self.context.delete(total)
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    // MARK: - ReminderEntity Operations

    func insertReminder(reminderDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            // Crear una solicitud de búsqueda para obtener el ID máximo actual
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ReminderEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reminderId", ascending: false)]
            fetchRequest.propertiesToFetch = ["reminderId"]
            fetchRequest.resultType = .dictionaryResultType
            
            var newID: Int64 = 1
            do {
                // Ejecutar la solicitud de búsqueda
                let results = try self.context.fetch(fetchRequest)
                if let maxDictionary = results.first as? [String: Int64], let maxId = maxDictionary["reminderId"] {
                    // Si se obtiene un resultado, incrementar en 1 el ID máximo actual
                    newID = maxId + 1
                }
            } catch {
                print("Error al obtener el ID máximo del recordatorio: \(error)")
                // Manejar el error como se considere necesario
                completion(false)
                return
            }

            // Crear una nueva instancia de ReminderEntity con el nuevo ID
            let newReminder = ReminderEntity(context: self.context)
            newReminder.reminderId = newID  // Usar el nuevo ID generado
            newReminder.userId = reminderDetails["userId"] as? Int64 ?? 0
            newReminder.reminderTitle = reminderDetails["reminderTitle"] as? String ?? ""
            newReminder.reminderCategory = reminderDetails["reminderCategory"] as? String ?? ""
            newReminder.reminderDate = reminderDetails["reminderDate"] as? String ?? ""
            newReminder.hour = reminderDetails["hour"] as? String ?? ""
            newReminder.reminderMount = reminderDetails["reminderMount"] as? Double ?? 0.0
            newReminder.userEmailReminder = reminderDetails["userEmailReminder"] as? String ?? ""

            do {
                try self.context.save()
                completion(true)
            } catch {
                print("Error al guardar el recordatorio: \(error)")
                completion(false)
            }
        }
    }


    func getAllReminders(completion: @escaping ([ReminderEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()

        context.perform {
            do {
                let reminders = try self.context.fetch(fetchRequest)
                completion(reminders)
            } catch {
                completion([])
            }
        }
    }
    func getReminderByEmail(email: String, completion: @escaping ([ReminderEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmailReminder == %@", email)

        context.perform {
            do {
                let reminders = try self.context.fetch(fetchRequest)
                completion(reminders)
            } catch {
                print("Error al obtener recordatorios: \(error)")
                completion([])
            }
        }
    }



    func updateReminder(reminder: ReminderEntity, reminderDetails: [String: Any], completion: @escaping (Bool) -> Void) {
        context.perform {
            reminder.reminderTitle = reminderDetails["reminderTitle"] as? String ?? reminder.reminderTitle
            reminder.reminderCategory = reminderDetails["reminderCategory"] as? String ?? reminder.reminderCategory
            reminder.reminderDate = reminderDetails["reminderDate"] as? String ?? reminder.reminderDate
            reminder.hour = reminderDetails["hour"] as? String ?? reminder.hour
            reminder.reminderMount = reminderDetails["reminderMount"] as? Double ?? reminder.reminderMount
            reminder.userEmailReminder = reminderDetails["userEmailReminder"] as? String ?? reminder.userEmailReminder

            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }


    func deleteReminder(reminder: ReminderEntity, completion: @escaping (Bool) -> Void) {
        context.perform {
            self.context.delete(reminder)
            do {
                try self.context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    // MARK: - NSFetchedResultsController for Real-Time UI Updates
    
    func fetchedResultsControllerForEntity<T: NSManagedObject>(entityName: String, sortDescriptors: [NSSortDescriptor], predicate: NSPredicate?) -> NSFetchedResultsController<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }
}

