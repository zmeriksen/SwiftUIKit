//
//  TableView.swift
//  SwiftUIKit
//
//  Created by Zach Eriksen on 4/12/20.
//

import UIKit

@available(iOS 11.0, *)
public protocol CellDisplayable {
    var cellID: String { get }
}

@available(iOS 11.0, *)
public protocol DataIdentifiable {
    static var ID: String { get }
}

@available(iOS 11.0, *)
public protocol CellUpdatable {
    func update(forData data: CellDisplayable)
}

@available(iOS 11.0, *)
public protocol CellConfigurable {
    func configure(forData data: CellDisplayable)
}

@available(iOS 11.0, *)
public typealias TableViewCell = DataIdentifiable & CellConfigurable & CellUpdatable & UITableViewCell

public typealias TableHeaderFooterViewHandler = (Int) -> UIView?
public typealias TableDidSelectIndexPathHandler = (IndexPath) -> Void
public typealias TableHighlightIndexPathHandler = (IndexPath) -> Bool

@available(iOS 11.0, *)
public class TableView: UITableView {
    public var data: [[CellDisplayable]]
    
    private var headerViewForSection: TableHeaderFooterViewHandler?
    private var footerViewForSection: TableHeaderFooterViewHandler?
    private var didSelectRowAtIndexPath: TableDidSelectIndexPathHandler?
    private var shouldHighlightRowAtIndexPath: TableHighlightIndexPathHandler?
    private var canEditRowAtIndexPath: ((IndexPath) -> Bool)?
    private var canMoveRowAtIndexPath: ((IndexPath) -> Bool)?
    private var canFocusRowAtIndexPath: ((IndexPath) -> Bool)?
    private var indentationLevelForRowAtIndexPath: ((IndexPath) -> Int)?
    private var shouldIndentWhileEditingRowAtIndexPath: ((IndexPath) -> Bool)?
    private var shouldShowMenuForRowAtIndexPath: ((IndexPath) -> Bool)?
    private var editingStyleForRowAtIndexPath: ((IndexPath) -> UITableViewCell.EditingStyle)?
    private var titleForDeleteConfirmationButtonForRowAtIndexPath: ((IndexPath) -> String)?
    private var editActionsForRowAtIndexPath: ((IndexPath) -> [UITableViewRowAction])?
    private var commitEditingStyleForRowAtIndexPath: ((UITableViewCell.EditingStyle, IndexPath) -> Void)?
    private var didDeselectRowAtIndexPath: ((IndexPath) -> Void)?
    private var willBeginEditingRowAtIndexPath: ((IndexPath) -> Void)?
    private var didEndEditingRowAtIndexPath: ((IndexPath?) -> Void)?
    private var didHighlightRowAtIndexPath: ((IndexPath) -> Void)?
    private var didUnhighlightRowAtIndexPath: ((IndexPath) -> Void)?
    private var moveRowAtSourceIndexPathToDestinationIndexPath: ((IndexPath, IndexPath) -> Void)?
    private var leadingSwipeActionsConfigurationForRowAtIndexPath: ((IndexPath) -> UISwipeActionsConfiguration)?
    private var trailingSwipeActionsConfigurationForRowAtIndexPath: ((IndexPath) -> UISwipeActionsConfiguration)?
    private var heightForHeaderInSection: ((Int) -> CGFloat)?
    private var heightForFooterInSection: ((Int) -> CGFloat)?
    
    public init(
        initalData: [[CellDisplayable]] = [[CellDisplayable]](),
        style: UITableView.Style = .plain
    ) {
        self.data = initalData
        super.init(frame: .zero, style: style)
        
        dataSource = self
        delegate = self
    }
    
    /// not implemented
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 11.0, *)
public extension TableView {
    @discardableResult
    func update(
        shouldReloadData: Bool = false,
        content: ([[CellDisplayable]]) -> [[CellDisplayable]]
    ) -> Self {
        data = content(data)
        
        if shouldReloadData {
            reloadData()
        }
        
        return self
    }
    
    @discardableResult
    func append(
        shouldReloadData: Bool = false,
        content: () -> [[CellDisplayable]]
    ) -> Self {
        data += content()
        
        if shouldReloadData {
            reloadData()
        }
        
        return self
    }
}

@available(iOS 11.0, *)
extension TableView: UITableViewDataSource, UITableViewDelegate {
    func sections() -> Int {
        data.count
    }
    
    func rows(forSection section: Int) -> Int {
        data[section].count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        sections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows(forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        indentationLevelForRowAtIndexPath?(indexPath) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = data[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellData.cellID, for: indexPath)
        
        if let configure = cell as? CellUpdatable {
            configure.update(forData: cellData)
        }
        
        guard cell.contentView.allSubviews.count == 0 else {
            return cell
        }
        
        if let configure = cell as? CellConfigurable {
            configure.configure(forData: cellData)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        heightForHeaderInSection?(section) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heightForFooterInSection?(section) ?? 0
    }
    
    // MARK: HeaderForSection
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerViewForSection?(section)
    }
    
    // MARK: FooterForSection
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerViewForSection?(section)
    }
    
    // MARK: CanRowAt
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEditRowAtIndexPath?(indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        canMoveRowAtIndexPath?(indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        canFocusRowAtIndexPath?(indexPath) ?? false
    }
    
    // MARK: ShouldRowAt
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        shouldHighlightRowAtIndexPath?(indexPath) ?? true
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        shouldIndentWhileEditingRowAtIndexPath?(indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        shouldShowMenuForRowAtIndexPath?(indexPath) ?? false
    }
    
    // MARK: Editing
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        editingStyleForRowAtIndexPath?(indexPath) ?? .none
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        titleForDeleteConfirmationButtonForRowAtIndexPath?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        editActionsForRowAtIndexPath?(indexPath)
    }
    
    // MARK: Actions
    
    public func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        commitEditingStyleForRowAtIndexPath?(editingStyle, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAtIndexPath?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didDeselectRowAtIndexPath?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        willBeginEditingRowAtIndexPath?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        didEndEditingRowAtIndexPath?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        didHighlightRowAtIndexPath?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        didUnhighlightRowAtIndexPath?(indexPath)
    }
    
    public func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        moveRowAtSourceIndexPathToDestinationIndexPath?(sourceIndexPath, destinationIndexPath)
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        leadingSwipeActionsConfigurationForRowAtIndexPath?(indexPath) ?? .none
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        trailingSwipeActionsConfigurationForRowAtIndexPath?(indexPath) ?? .none
    }
}

@available(iOS 11.0, *)
public extension TableView {
    @discardableResult
    func set(dataSource: UITableViewDataSource) -> Self {
        self.dataSource = dataSource
        
        return self
    }
    
    @discardableResult
    func set(delegate: UITableViewDelegate) -> Self {
        self.delegate = delegate
        
        return self
    }
    
    @discardableResult
    func register(cells: [TableViewCell.Type]) -> Self {
        cells.forEach {
            register($0, forCellReuseIdentifier: $0.ID)
        }
        
        return self
    }
    
    @discardableResult
    func headerView(_ handler: @escaping TableHeaderFooterViewHandler) -> Self  {
        headerViewForSection = handler
        
        return self
    }
    
    @discardableResult
    func footerView(_ handler: @escaping TableHeaderFooterViewHandler) -> Self  {
        footerViewForSection = handler
        
        return self
    }
    
    @discardableResult
    func headerHeight(_ handler: @escaping (Int) -> CGFloat) -> Self  {
        heightForHeaderInSection = handler
        
        return self
    }
    
    @discardableResult
    func footerHeight(_ handler: @escaping (Int) -> CGFloat) -> Self  {
        heightForFooterInSection = handler
        
        return self
    }
    
    @discardableResult
    func indentationLevelForRowAtIndexPath(_ handler: @escaping (IndexPath) -> Int) -> Self  {
        indentationLevelForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func canEditRowAtIndexPath(_ handler: @escaping (IndexPath) -> Bool) -> Self {
        canEditRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func canMoveRowAtIndexPath(_ handler: @escaping (IndexPath) -> Bool) -> Self {
        canMoveRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func canFocusRowAtIndexPath(_ handler: @escaping (IndexPath) -> Bool) -> Self {
        canFocusRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func shouldHighlightRow(_ handler: @escaping TableHighlightIndexPathHandler) -> Self {
        shouldHighlightRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func shouldIndentWhileEditingRowAtIndexPath(_ handler: @escaping (IndexPath) -> Bool) -> Self {
        shouldIndentWhileEditingRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func shouldShowMenuForRowAtIndexPath(_ handler: @escaping (IndexPath) -> Bool) -> Self {
        shouldShowMenuForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func editingStyleForRowAtIndexPath(_ handler: @escaping (IndexPath) -> UITableViewCell.EditingStyle) -> Self {
        editingStyleForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func titleForDeleteConfirmationButtonForRowAtIndexPath(_ handler: @escaping (IndexPath) -> String) -> Self {
        titleForDeleteConfirmationButtonForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func editActionsForRowAtIndexPath(_ handler: @escaping (IndexPath) -> [UITableViewRowAction]) -> Self {
        editActionsForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func commitEditingStyleForRowAtIndexPath(_ handler: @escaping (UITableViewCell.EditingStyle, IndexPath) -> Void) -> Self {
        commitEditingStyleForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func didSelectRow(_ handler: @escaping TableDidSelectIndexPathHandler) -> Self {
        didSelectRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func didDeselectRowAtIndexPath(_ handler: @escaping (IndexPath) -> Void) -> Self {
        didDeselectRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func willBeginEditingRowAtIndexPath(_ handler: @escaping (IndexPath) -> Void) -> Self {
        willBeginEditingRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func didEndEditingRowAtIndexPath(_ handler: @escaping (IndexPath?) -> Void) -> Self {
        didEndEditingRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func didHighlightRowAtIndexPath(_ handler: @escaping (IndexPath) -> Void) -> Self {
        didHighlightRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func didUnhighlightRowAtIndexPath(_ handler: @escaping (IndexPath) -> Void) -> Self {
        didUnhighlightRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func moveRowAtSourceIndexPathToDestinationIndexPath(_ handler: @escaping (IndexPath, IndexPath) -> Void) -> Self {
        moveRowAtSourceIndexPathToDestinationIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func leadingSwipeActionsConfigurationForRowAtIndexPath(_ handler: @escaping (IndexPath) -> UISwipeActionsConfiguration) -> Self {
        leadingSwipeActionsConfigurationForRowAtIndexPath = handler
        
        return self
    }
    
    @discardableResult
    func trailingSwipeActionsConfigurationForRowAtIndexPath(_ handler: @escaping (IndexPath) -> UISwipeActionsConfiguration) -> Self {
        trailingSwipeActionsConfigurationForRowAtIndexPath = handler
        
        return self
    }
}
