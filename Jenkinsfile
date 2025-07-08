
@Library([
  'pipe-build-lib',
  'ces-build-lib',
  'dogu-build-lib'
]) _

def pipe = new com.cloudogu.sos.pipebuildlib.DoguPipe(this, [
    doguName           : "redis",
    doBatsTests         : true,
    shellScripts       : ['''
                          resources/startup.sh
                          resources/util.sh
                          '''
    ]
])

pipe.setBuildProperties()
pipe.addDefaultStages()
pipe.run()
