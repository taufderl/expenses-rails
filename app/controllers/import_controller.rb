class ImportController < ApplicationController
  before_action :authenticate_user!

  def index
  end
  
  def upload
    @file = params[:upload][:file]
    @format = params[:upload][:format]
    
    case @format
    when 'ing'
      parse_ing_file
    when 'sparkasse'
      parse_sparkasse_file
    when 'dkb_credit'
      parse_dkb_credit_file
    when 'dkb_giro'
      parse_dkb_giro_file
    else
      parse_default
    end
  end
  
  def parse_dkb_credit_file
    @filecontent = @file.read
    @filecontent.force_encoding('ISO-8859-1')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ";")
    @content = @csv.to_a.map {|row| row.to_hash }
    tag = "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S")
    import_category = Category.create(name: "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S"), user: current_user)
    @create = true
    @debug = []
    @content.each do |row|
      category = import_category
      subcategory = nil
      if row["Umsatzbeschreibung"] == "Abgeltungsteuer"
        category = Category.find_by(name: "Contracts")
        subcategory = Subcategory.find_by(category: category, name: "Bank Fees")
      elsif row["Umsatzbeschreibung"].include? "NETFLIX"
        category = Category.find_by(name: "Contracts")
        subcategory = Subcategory.find_by(category: category, name: "Netflix")
      elsif row["Umsatzbeschreibung"].include? "DB BAHN"
        category = Category.find_by(name: "Transport")
        subcategory = Subcategory.find_by(category: category, name: "Train")
      end 
      if row["Betrag (EUR)"][0] == '-'
        #if Auszahlung
      else
        #else it is a Einzahlung, irgnore
        @create = false
      end
      if @create
        begin
          e = Expense.create(
              amount: row["Betrag (EUR)"].sub(",", ".").sub("-", ""),
              to: row["Umsatzbeschreibung"],
              date: Date.strptime(row["Belegdatum"],"%d.%m.%Y"),
              note: row["Verwendungszweck"],
              tag_list: tag,
              category: category,
              subcategory: subcategory,
              source: :dkb_credit,
              user: current_user
          )
        rescue => err
          @debug.append({row: row, err: err})
        end
      end
      @create = true

    end
  end

def parse_dkb_giro_file
    @filecontent = @file.read
    @filecontent.force_encoding('ISO-8859-1')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ";", encoding: 'ISO-8859-1')
    @content = @csv.to_a.map {|row| row.to_hash }
    tag = "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S")
    import_category = Category.create(name: "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S"), user: current_user)
    @create = true
    @debug = []
    @content.each do |row|
      category = import_category
      subcategory = nil
      if row["Auftraggeber / Begunstigter"].include? "VERSICHERUNG"
        category = Category.find_by(name: "Insurance")
      end 
      if row["Betrag (EUR)"][0] == '-'
        #else it is a Einzahlung
      else
        @create = false
      end
      if row["Verwendungszweck"].include? "TIM AUF DER LANDWEHR"
        @create = false
      end
      if @create
        begin
          e = Expense.create(
              amount: row["Betrag (EUR)"].sub(",", ".").sub("-", ""),
              to: row["Auftraggeber / Begunstigter"],
              date: Date.strptime(row["Buchungstag"],"%d.%m.%Y"),
              note: row["Verwendungszweck"],
              tag_list: tag,
              category: category,
              subcategory: subcategory,
              source: :dkb_giro,
              user: current_user
          )
        rescue => err
          @debug.append({row: row, err: err})
        end
      end
      @create = true
    end
  end

  
  def parse_sparkasse_file
    @filecontent = @file.read
    @filecontent.force_encoding('ISO-8859-1')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ";", encoding: "ISO-8859-1")
    @content = @csv.to_a.map {|row| row.to_hash }
    tag = "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S")
    import_category = Category.create(name: "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S"), user: current_user)
    @create = true
    @debug = []
    @content.each do |row|
      category = import_category
      subcategory = nil
      case row["Buchungstext"]
      when "FOLGELASTSCHRIFT"
      when "EIGENE KREDITKARTENABRECHN."
      when "ENTGELTABSCHLUSS"
        category = Category.find_by_name("Contracts")
        subcategory = Subcategory.find_by(category: category, name: "Bank Fees")
      when "ERSTLASTSCHRIFT"
      when "LADEVORGANG PREPAID - KARTE"
      when "LASTSCHRIFT"
      when "ONLINE-UEBERWEISUNG"
      when "SONSTIGER EINZUG"
      else
        @create = false
      end
      if row["Beguenstigter/Zahlungspflichtiger"] == "WERTGARANTIE AG"
        category = Category.find_by_name("Insurance")
      end
      if row["Beguenstigter/Zahlungspflichtiger"].include? "HB-HANDY-LADEN"
        category = Category.find_by_name("Contracts")
        subcategory = Subcategory.find_by(category: category, name: "Mobile Phone")
      end
      if @create
        begin
          row["Beguenstigter/Zahlungspflichtiger"].gsub('\xC3\xB6','ö')
          if row["Valutadatum"] == "29.02.14"
            row["Valutadatum"] = "28.02.14"
          elsif row["Valutadatum"] == "29.02.13"
            row["Valutadatum"] = "28.02.13"
          end
          
          e = Expense.create(
              amount: row["Betrag"].sub(",", ".").sub("-", ""),
              to: row["Beguenstigter/Zahlungspflichtiger"],
              date: Date.strptime(row["Valutadatum"],"%d.%m.%y"),
              note: row["Verwendungszweck"],
              tag_list: tag,
              category: category,
              subcategory: subcategory,
              source: :sparkasse,
              user: current_user
          )
        rescue => err
          @debug.append({row: row, err: err})
        end
      end
      @create = true
    end
  end
  
  def parse_ing_file
    @csv = CSV.new(@file.read, headers: true)
    @content = @csv.to_a.map {|row| row.to_hash }
    tag = "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S")
    import_category = Category.create(name: "Import_"+@format+"_"+Time.now.strftime("%Y-%m-%d-%H%M%S"), user: current_user)
    @create = true
    @debug = []
    @content.each do |row|
      category = import_category
      subcategory = nil
      case row["MutatieSoort"]
      when "Betaalautomaat"
        if row['Datum'] < "201411"
          date = Date.strptime(row["Naam / Omschrijving"][0..5] + '2014',"%d-%m-%Y")
          to = row["Mededelingen"]
          note = row["Naam / Omschrijving"]
        else
          date = row["Mededelingen"][15..24]
          to = row["Naam / Omschrijving"]
          note = row["Mededelingen"]
        end
        if ['Jumbo', 'ALBERT', 'PLUS', 'AH to go'].any? { |str| row["Naam / Omschrijving"].include? str}
          category = Category.find_by_name("Groceries")
        elsif ['Billy', 'Subway', 'TACO'].any? { |str| row["Naam / Omschrijving"].include? str}
          category = Category.find_by_name("Meals")
        end
      when "Incasso"
        date = Date.strptime(row["Datum"],"%Y%m%d")
        to = row["Naam / Omschrijving"]
        note = row["Mededelingen"]
        if ['Zorgverzekeraar', 'NATIONALE NEDERLANDEN'].any? { |str| row["Naam / Omschrijving"].include? str}
          category = Category.find_by_name("Insurance")
        elsif ['Simyo'].any? { |str| row["Naam / Omschrijving"].include? str}
          category = Category.find_by_name("Contracts")
          subcategory = Subcategory.find_by(category: category, name: "Mobile Phone")
        end
        
      when "Internetbankieren"
        if not row["Tegenrekening"].empty?
          to = row["Naam / Omschrijving"]
          date = row["Datum"]
          note = row["Mededelingen"]
        else
          @create = false
        end
      when "Diversen"
        to = row["Naam / Omschrijving"]
        date = row["Datum"]
        note = row["Mededelingen"]
        category = Category.find_by_name("Contracts")
        subcategory = Subcategory.find_by(category: category, name: "Bank Fees")
      else
        @create = false
      end
      if @create
        begin
          e = Expense.create(
              amount: row["Bedrag (EUR)"].sub(",", "."),
              to: to,
              date: date,
              note: note,
              category: category,
              subcategory: subcategory,
              tag_list: tag,
              source: :ing,
              user: current_user
          )
        rescue => err
          @debug.append({row: row, err: err})
        end
      end
      @create = true
    end 
  end
  
  
  def parse_default
    require "roo"
    @sheet = Roo::Spreadsheet.open(@file)
    
    @entries = @sheet.parse(date: "Datum", to: "Wo", category: "Kategorie", note: "Details", amount: "Preis")
    
    @print = []
    @entries.each do |entry|
      begin
        category = Category.where(user: current_user).find_by(name: entry[:category])
        if not category
          c = Category.create(name: entry[:category], user: current_user)
        else
          c = category
        end
        entry[:category] = c
        Expense.create(entry.merge({user: current_user}))
      rescue => error
        @print = @print + [entry, error]
      end
    end
    @print = @print + [@print.length]
  end
end
