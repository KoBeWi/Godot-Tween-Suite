@tool
extends Control

var tweener: TweenAnimation.TweenerAnimator

func set_tweener(tw: TweenAnimation.TweenerAnimator):
	tweener = tw
	%Type.text = tweener.get_name()
	
	
