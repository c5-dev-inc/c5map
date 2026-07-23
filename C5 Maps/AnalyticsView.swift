//
//  AnalyticsView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-14.
//

import SwiftUI
import Charts

// MARK: - Analytics Data Models
struct AnalyticsMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
}

struct WeeklyDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let views: Int
    let taps: Int
}

struct ProductPerformance: Identifiable {
    let id = UUID()
    let name: String
    let views: Int
    let taps: Int
    let revenue: Double
}

// MARK: - Analytics Sheet
struct AnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeRange = 0
    let timeRanges = ["7 Days", "30 Days", "90 Days"]
    
    // MARK: - Mock Data
    let metrics: [AnalyticsMetric] = [
        AnalyticsMetric(title: "Store Views", value: "1,847", change: "+12.5%", isPositive: true, icon: "eye.fill", color: .blue),
        AnalyticsMetric(title: "Location Views", value: "3,421", change: "+8.3%", isPositive: true, icon: "location.fill", color: .green),
        AnalyticsMetric(title: "Website Taps", value: "892", change: "+5.7%", isPositive: true, icon: "globe", color: .purple),
        AnalyticsMetric(title: "Revenue", value: "$2,847", change: "+15.2%", isPositive: true, icon: "dollarsign.circle.fill", color: .orange),
    ]
    
    let weeklyData: [WeeklyDataPoint] = [
        WeeklyDataPoint(day: "Mon", views: 320, taps: 45),
        WeeklyDataPoint(day: "Tue", views: 280, taps: 38),
        WeeklyDataPoint(day: "Wed", views: 410, taps: 62),
        WeeklyDataPoint(day: "Thu", views: 390, taps: 55),
        WeeklyDataPoint(day: "Fri", views: 520, taps: 78),
        WeeklyDataPoint(day: "Sat", views: 450, taps: 68),
        WeeklyDataPoint(day: "Sun", views: 380, taps: 52),
    ]
    
    let topProducts: [ProductPerformance] = [
        ProductPerformance(name: "Latte", views: 567, taps: 89, revenue: 124.50),
        ProductPerformance(name: "Croissant", views: 423, taps: 67, revenue: 89.25),
        ProductPerformance(name: "Mocha", views: 389, taps: 56, revenue: 76.80),
        ProductPerformance(name: "Pastry Box", views: 245, taps: 34, revenue: 45.60),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(0..<timeRanges.count, id: \.self) { index in
                            Text(timeRanges[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // MARK: - Metrics Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(metrics) { metric in
                            AnalyticsMetricCard(metric: metric)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Weekly Performance Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Performance")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(weeklyData) { dataPoint in
                                BarMark(
                                    x: .value("Day", dataPoint.day),
                                    y: .value("Views", dataPoint.views)
                                )
                                .foregroundStyle(Color.blue.gradient)
                                .annotation(position: .top) {
                                    Text("\(dataPoint.views)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        
                        // Chart Legend
                        HStack(spacing: 20) {
                            Label("Views", systemImage: "square.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Label("\(weeklyData.reduce(0) { $0 + $1.views }) Total Views", systemImage: "eye")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // MARK: - Top Products
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Products")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("Product")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Text("Views")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .trailing)
                                
                                Text("Taps")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .trailing)
                                
                                Text("Revenue")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            
                            ForEach(Array(topProducts.enumerated()), id: \.element.id) { index, product in
                                VStack(spacing: 0) {
                                    HStack {
                                        // Product Name with Rank
                                        HStack(spacing: 8) {
                                            Text("#\(index + 1)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.secondary)
                                                .frame(width: 20)
                                            
                                            Text(product.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .frame(width: 60, alignment: .leading)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(product.views)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 50, alignment: .trailing)
                                        
                                        Text("\(product.taps)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 50, alignment: .trailing)
                                        
                                        Text("$\(String(format: "%.2f", product.revenue))")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                            .frame(width: 70, alignment: .trailing)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(index % 2 == 0 ? Color(.systemBackground) : Color(.systemGray6).opacity(0.3))
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // MARK: - Summary Card
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            SummaryItem(
                                icon: "person.fill",
                                color: .blue,
                                title: "Unique Visitors",
                                value: "1,234"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            SummaryItem(
                                icon: "clock.fill",
                                color: .green,
                                title: "Avg. Time",
                                value: "4m 32s"
                            )
                        }
                        
                        Divider()
                        
                        HStack(spacing: 20) {
                            SummaryItem(
                                icon: "arrow.clockwise",
                                color: .purple,
                                title: "Return Rate",
                                value: "34%"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            SummaryItem(
                                icon: "star.fill",
                                color: .yellow,
                                title: "Avg. Rating",
                                value: "4.8"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Export action
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

// MARK: - Analytics Metric Card
struct AnalyticsMetricCard: View {
    let metric: AnalyticsMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: metric.icon)
                    .font(.title3)
                    .foregroundColor(metric.color)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: metric.isPositive ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                        .foregroundColor(metric.isPositive ? .green : .red)
                    Text(metric.change)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(metric.isPositive ? .green : .red)
                }
            }
            
            Text(metric.value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(metric.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Summary Item
struct SummaryItem: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    AnalyticsView()
}
