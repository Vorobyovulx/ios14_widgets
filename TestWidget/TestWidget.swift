//
//  TestWidget.swift
//  TestWidget
//
//  Created by Mad Brains on 04.12.2020.
//

import WidgetKit
import SwiftUI
import Intents

// Ядро виджета. Отвечает за подпитку виджета данными и установку интервалов обновления данных
struct Provider: IntentTimelineProvider {
    
    //    Когда WidgetKit отображает ваш виджет впервые, он отображает представление виджета в качестве заполнителя. Представление-заполнитель отображает общее представление вашего виджета, давая пользователю общее представление о том, что показывает виджет.
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "Some text for preview", configuration: ConfigurationIntent())
    }

    //    WidgetKit запрашивает моментальный снимок в переходных ситуациях, таких как предварительный просмотр в галерее виджетов.
    //    Мы возвращаем одну запись на временной шкале, представляющую текущее время и состояние.
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: "This is text for preview", configuration: configuration)
        completion(entry)
    }

    func getData() -> String {
        
        return "some"
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let date = Date()
        
        let entry = SimpleEntry(
            date: date,
            text: getData(),
            configuration: configuration
        )
        
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdateDate)
        )
        
        completion(timeline)
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let text: String
    let configuration: ConfigurationIntent
}

struct TestWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry

    var body: some View {
        
        switch family {
            case .systemSmall: SmallWidgetView(entry: entry)
            case .systemMedium: MediumWidgetView(entry: entry)
            default: SmallWidgetView(entry: entry)
        }
    }
    
}

struct SmallWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("\(entry.text)")
    }
    
}

struct MediumWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Hello world!")
            Text("\(entry.text)").fontWeight(.bold)
        }
    }
    
}


// Виджет для отображается в нормальных условиях.
@main
struct TestWidget: Widget {
    // Отличительный идентификатор
    let kind: String = "TestWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider(),// Ядро виджета. Отвечает за подпитку виджета данными и установку интервалов обновления данных
            content: { entry in
                TestWidgetEntryView(entry: entry)
            }
        )
        // Отображается на панели управления при добавлении виджета
        .configurationDisplayName("Имя виджета")
        .description("Описание виджета")
        // Поддерживаемые типоразмеры виджетов
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Превьюха на случай, когда нет данных для отображения - например, когда пользователь только что установил и еще не открыл ваше приложение, но разместил виджет на экране.
struct TestWidget_Previews: PreviewProvider {
    static var previews: some View {
        TestWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Some text", configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
