describe "SlideCtrl", ->
  fakeLocation = null
  scope = null
  slideCtrl = null

  beforeEach ->
    fakeLocation =
      _slide: 0
      path: -> "/slides/#{@_slide}"
    sinon.spy(fakeLocation, "path")

  beforeEach module('ourApp')

  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    ctrl = $controller "SlideCtrl",
      $rootScope: scope
      $location: fakeLocation
      SLIDE_COUNT: 16
    slideCtrl = scope.slideCtrl

  describe ".next()", ->
    it "should advance to the next slide", ->
      slideCtrl.setIndex = sinon.spy()
      slideCtrl.getCurrent = -> 2
      slideCtrl.next()
      slideCtrl.setIndex.should.have.been.calledWith(3)

  describe ".previous()", ->
    it "should advance to the next slide", ->
      slideCtrl.setIndex = sinon.spy()
      slideCtrl.getCurrent = -> 2
      slideCtrl.previous()
      slideCtrl.setIndex.should.have.been.calledWith(1)

  describe ".getCurrent()", ->
    it "should return the current slide index", ->
      fakeLocation._slide = 5
      slideCtrl.getCurrent().should.equal(5)
      fakeLocation._slide = 0
      slideCtrl.getCurrent().should.equal(0)
      fakeLocation._slide = 10
      slideCtrl.getCurrent().should.equal(10)

  describe ".setIndex()", ->
    it "should not do anything if the index is not valid", ->
      slideCtrl.isIndexValid = sinon.spy(-> false)
      slideCtrl.setIndex(5)
      slideCtrl.isIndexValid.should.have.been.calledWith(5)
      fakeLocation.path.should.not.have.been.called

    it "should navigate to the correct slide", ->
      slideCtrl.isIndexValid = -> true
      scope.$apply = sinon.spy()
      slideCtrl.setIndex(4)
      fakeLocation.path.should.have.been.calledWith("/slides/4")
      scope.$apply.should.have.been.called

  describe ".isIndexValid", ->
    it "should return false if index is under zero", ->
      slideCtrl.isIndexValid(-1).should.equal(false)
      slideCtrl.isIndexValid(-10000).should.equal(false)

    it "should return false if the index is above limit", ->
      slideCtrl.isIndexValid(16).should.equal(false)
      slideCtrl.isIndexValid(17000).should.equal(false)

    it "should return true if the index is valid", ->
      slideCtrl.isIndexValid(15).should.equal(true)
      slideCtrl.isIndexValid(1).should.equal(true)
