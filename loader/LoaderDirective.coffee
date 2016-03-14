###
    A simple directive that shows a loading spinner.

    until:        Model that changes, accept Promises and Array of Promise.
    delay:        Number of milliseconds required for the spinner to start.
    minimum:      Number of milliseconds the spinner will stay active.
    as-long-as:   Bypass the until. It is evaluated as a Boolean.
    start-hidden: Hide the content by default.

    <[loader|ANY]
      until="Object|Promise|[Object|Promise, ...]"
      as-long-as="true|false"
      [delay="Number"]
      [minimum="Number"]
      [start-hidden]
    >
        [Stuff to hide]
    </[loader|ANY]>

    Example:
      <button>
          Search<loader until="expression" [delay="Number"] [minimum="Number"] />
      </button>

###
loader = angular.module 'angular.loader', [
  'ajoslin.promise-tracker'
]

loader.directive('loader', [
  '$q', '$timeout', 'promiseTracker',
  ($q, $timeout, promiseTracker)->
    directive = {
      transclude: true
      restrict: 'AE'
      scope:
        conditions: '=until'
        expression: '=asLongAs'
        delay: '='
        minimum: '='
      link: (scope, element, attrs, ctrl, transclude) ->
        scope.tracker = promiseTracker({
          activationDelay: scope.delay || 0
          minDuration: scope.minimum || 0
        })

        scope.startHidden = attrs['startHidden']? || false

        # Cancel the tracker on destroy.
        element.on('$destroy', ->
          scope.tracker.cancel()
        )

        scope.$watchCollection 'conditions', (newConditions, oldConditions) ->
          return unless newConditions != oldConditions

          if newConditions?
            scope.startHidden = false

          # Threat everything as an array
          conditions = [].concat(newConditions)
          for condition in conditions
            scope.tracker.addPromise $q.when(condition) if condition?


        transclude (clone, innerScope)->
          innerScope.$tracker = scope.tracker
          if clone? and clone.length > 0
            scope.needTransclude = true

      template: """
<div class="loader"
     ng-show="!!expression || (tracker.active() && !startHidden)">
  <span></span>
  <span></span>
  <span></span>
</div>
<div ng-if="needTransclude" ng-transclude ng-show="!(!!expression || (tracker.active() && !startHidden))"></div>
"""
    }
    return directive
])
