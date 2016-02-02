//
//  FlickrSearchViewFlowLayout.swift
//  FlickrSearch
//
//  Created by SeokWon Cheul on 2016. 1. 29..
//  Copyright © 2016년 Richard turton. All rights reserved.
//

import UIKit

class FlickrSearchViewFlowLayout: UICollectionViewFlowLayout, UICollisionBehaviorDelegate {
    
    var dynamicAnimator:UIDynamicAnimator!
    var visibleIndexPathsSet:Set<NSIndexPath>!
    var latestDelta:CGFloat!
//    var collisionBehaviour:UICollisionBehavior!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.latestDelta = 0.0
        self.visibleIndexPathsSet = Set<NSIndexPath>()
        self.dynamicAnimator = UIDynamicAnimator(collectionViewLayout:self)
//        self.collisionBehaviour = UICollisionBehavior(items: [])
//        self.dynamicAnimator.addBehavior(self.collisionBehaviour)
//        self.collisionBehaviour.collisionMode = UICollisionBehaviorMode.Items
//        self.collisionBehaviour.translatesReferenceBoundsIntoBoundary = true
    }
    override func prepareLayout() {
        super.prepareLayout()
        
        let originalRect = CGRect(origin: self.collectionView!.bounds.origin,
            size: self.collectionView!.frame.size)
        let visibleRect = CGRectInset(originalRect, -400, -400)
        let itemsInVisibleRectArray = super.layoutAttributesForElementsInRect(visibleRect)! as NSArray
        let itemsIndexPathsInVisibleRectSet = NSSet(array: itemsInVisibleRectArray.valueForKey("indexPath") as! [NSIndexPath])
        
        let invisiblePredicate = NSPredicate { (obj, binding) -> Bool in
            if obj is UICollisionBehavior
            {
                return true
            }
            let behaviour = obj as! UIAttachmentBehavior
            let item = behaviour.items.first as! UICollectionViewLayoutAttributes
            let currentlyVisible = itemsIndexPathsInVisibleRectSet.member(item.indexPath) != nil
            return !currentlyVisible
        }
        let noLongerVisibleBehaviours = (self.dynamicAnimator.behaviors as NSArray).filteredArrayUsingPredicate(invisiblePredicate)
        
        (noLongerVisibleBehaviours as NSArray).enumerateObjectsUsingBlock { (object, index, stop) -> Void in
            if object is UICollisionBehavior
            {
                return
            }
            self.dynamicAnimator.removeBehavior(object as! UIDynamicBehavior)
            let item = (object as! UIAttachmentBehavior).items.first as! UICollectionViewLayoutAttributes
            self.visibleIndexPathsSet.remove(item.indexPath)
//            self.collisionBehaviour.removeItem(item)
            
        }
        
        let visiblePredicate = NSPredicate { (object, binding) -> Bool in
            if object is UICollisionBehavior
            {
                return false
            }
            let item = (object as! UICollectionViewLayoutAttributes)
            let currentlyVisible = self.visibleIndexPathsSet.contains(item.indexPath)
            return !currentlyVisible
        }
        
        let newlyVisibleItems = itemsInVisibleRectArray.filteredArrayUsingPredicate(visiblePredicate) as! [UICollectionViewLayoutAttributes]
        
        let touchLocation = self.collectionView!.panGestureRecognizer.locationInView(self.collectionView!)
        
        for (_, item) in newlyVisibleItems.enumerate()
        {
            var center = item.center

            let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: center)
            springBehaviour.length = 0.0
            springBehaviour.damping = 0.8
            springBehaviour.frequency = 1.0
            if CGPointEqualToPoint(CGPointZero, touchLocation)
            {
                let yDistanceFromTouch = fabsf(Float(touchLocation.y - springBehaviour.anchorPoint.y))
                let scrollResistance = yDistanceFromTouch / 1500.0
                
                if self.latestDelta < 0
                {
                    center.y += max(self.latestDelta, self.latestDelta * CGFloat(scrollResistance))
                }
                else
                {
                    center.y += min(self.latestDelta, self.latestDelta * CGFloat(scrollResistance))
                    
                }
                item.center = center
            }
//            self.collisionBehaviour.addItem(item)
            self.dynamicAnimator.addBehavior(springBehaviour)
            self.visibleIndexPathsSet.insert(item.indexPath)

        }
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.dynamicAnimator.itemsInRect(rect) as? [UICollectionViewLayoutAttributes]
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.dynamicAnimator.layoutAttributesForCellAtIndexPath(indexPath)
    }
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        
        let scrollView:UIScrollView = self.collectionView!
        let delta:CGFloat = newBounds.origin.y - scrollView.bounds.origin.y
        let touchLocation = self.collectionView!.panGestureRecognizer.locationInView(self.collectionView)
        self.latestDelta = delta
        
        (self.dynamicAnimator.behaviors as NSArray).enumerateObjectsUsingBlock {
            (obj, index, stop) -> Void in
            if obj is UICollisionBehavior
            {
                return
            }
            let springBehaviour = obj as! UIAttachmentBehavior
            let yDistanceFromTouch = fabsf(Float(touchLocation.y - springBehaviour.anchorPoint.y))
            let scrollResistance = yDistanceFromTouch / 1500.0
            
            let item = springBehaviour.items.first!
            var center = item.center
            if delta < 0 // swipe up
            {
                center.y += max(delta, delta * CGFloat(scrollResistance))
            }
            else // swipe down
            {
                center.y += min(delta, delta * CGFloat(scrollResistance))
                
            }
            item.center = center
            self.dynamicAnimator.updateItemUsingCurrentState(item)
        }
        return false
    }
    func resetLayout()
    {
        self.dynamicAnimator.removeAllBehaviors()
//        self.dynamicAnimator.addBehavior(self.collisionBehaviour)
        self.prepareLayout()
    }
}
